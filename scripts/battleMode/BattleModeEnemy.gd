extends KinematicBody2D

export var bulletScene : PackedScene #packed scene of the bullet this enemy uses
var bullet = null
export var approachTime = 2 # how long in seconds enemy takes to approach
export(String, FILE, "*.json") var attackPatternFile #imported json file
var attackPatternData #json file in text form so I can use it
var isAttackPhase = false # means that the player should be dodging, cant attack
var origScale = 0.1 # starting size of sprite when enemy spawns
export var finalScale = 1 #final size of the sprite once it has approached
var loopStart = 1 #line of the json where the enemies continous attack loop starts
var loopEnd = 2
var bulletsPerDodgePhase = 10 #how many bullets they spawn during each dodge phase before approaching again
var currAttack = 1 #current line of json file
var currBullets = 0
var bulletTimeMultiplier = 1 #always multiplied onto bullets speed when they are spawned, when time is reversed, this is changed to -1
var bulletTimeMultiplierNotZero = 1 # storage variable for bullet speed when resuming time

signal attackPhaseStarting
signal attackPhaseEnding

#SETUP AND APPROACH

func _ready():
	$ApproachTimer.wait_time = approachTime
	attackPatternData = getAttackPatternData() #get the json file and get it as a string
	if get_parent():
		connect("attackPhaseStarting", get_parent(), "on_attack_phase_starting")
		connect("attackPhaseEnding", get_parent(), "on_attack_phase_ending")
func approach(): #stop attacking and slowly approach player
	$ApproachTimer.start()
	$AnimatedSprite.play("moving")
	$AnimatedSprite.scale.x = origScale
	$AnimatedSprite.scale.y = origScale
	visible = true
	isAttackPhase = false 
	emit_signal("attackPhaseEnding")
func _physics_process(delta):
	if not isAttackPhase: #increase scale (grow bigger each frame)
		$AnimatedSprite.scale.x += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta 
		$AnimatedSprite.scale.y += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta
func _on_ApproachTimer_timeout(): #when timer finishes, sprite is proper size
	isAttackPhase = true #stop growing
	emit_signal("attackPhaseStarting")
	$AnimatedSprite.play("idle")
	startFight()
func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting


#FIGHT AND BULLET SPAWNING

func startFight():
	loopStart = attackPatternData[0]['loopStart'] #iterated through json file
	loopEnd = attackPatternData[0]['loopEnd']
	currAttack = loopStart
	currBullets = 0
	attack()
	
func attack():
	$bulletSpawnTimer.wait_time = attackPatternData[currAttack]['waitTime'] / abs(bulletTimeMultiplier) #time in between bullets spawning
	$bulletSpawnTimer.start()
func _on_bulletSpawnTimer_timeout():
	bullet = bulletScene.instance()
	bullet.position.x = attackPatternData[currAttack]['spawnLocationX'] - position.x
	bullet.position.y = $bulletSpawnLocationY.position.y
	bullet.speed *= bulletTimeMultiplier
	add_child(bullet)
	currAttack += 1
	currBullets += 1
	if currAttack > loopEnd:
		currAttack = loopStart
	if (currBullets < bulletsPerDodgePhase):
		attack()
	else:
		$bulletSpawnTimer.stop()
		approach()
	
#TIME FUNCTIONS

func reverseTime():
	bulletTimeMultiplier *= -1 
	$bulletSpawnTimer.paused = not $bulletSpawnTimer.paused
func speedUpTime(multiplier : int = 2):
	bulletTimeMultiplier = sign(bulletTimeMultiplier) * multiplier
func stopTime():
	bulletTimeMultiplierNotZero = bulletTimeMultiplier
	bulletTimeMultiplier = 0
	$bulletSpawnTimer.paused = true
	$AnimatedSprite.playing = false
func resumeTime():
	bulletTimeMultiplier = bulletTimeMultiplierNotZero
	$bulletSpawnTimer.paused = false
	$AnimatedSprite.playing = true

#TAKE DAMAGE

func getHit(damage:int):
	print("enemy: ouch")

#HELPER

func getAttackPatternData():
	attackPatternData = File.new() 
	if attackPatternData.file_exists(attackPatternFile): #get the attack pattern json file from the enemy node
		attackPatternData.open(attackPatternFile, attackPatternData.READ)
		return parse_json(attackPatternData.get_as_text())





