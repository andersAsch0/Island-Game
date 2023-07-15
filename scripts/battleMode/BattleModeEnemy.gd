extends KinematicBody2D

export var bulletScene : PackedScene #packed scene of the bullet this enemy uses
var bullet = null
export var approachTime = 4 # how long in seconds enemy takes to approach
export(String, FILE, "*.json") var attackPatternFile #imported json file
var attackPatternData #json file in text form so I can use it
var isAttackPhase = false # means that the player should be dodging, cant attack
var origScale = 0.1 # starting size of sprite when enemy spawns
export var finalScale = 1 #final size of the sprite once it has approached
var loopStart = 1 #line of the json where the enemies continous attack loop starts
export var enemySpeed = 50 #speed at which the enemy wanders around
export var maxHP = 5
var currentHP = maxHP
var loopEnd = 2
var bulletsPerAttackPhase = 30 #how many bullets they spawn during each attack phase before approaching again
var currAttack = 1 #current line of json file
var currBullets = 0
var bulletTimeMultiplier : float = 1 #always multiplied onto bullets speed when they are spawned, when time is reversed, this is changed to -1
var bulletTimeMultiplierNotZero : float = 1 # storage variable for bullet speed when resuming time

signal attackPhaseStarting
signal attackPhaseEnding
signal enemyDead

#SETUP AND APPROACH

func _ready():
	$enemyMovement.enemySpeed = enemySpeed
	attackPatternData = getAttackPatternData() #get the json file and get it as a string
	if get_parent():
		connect("attackPhaseStarting", get_parent(), "on_attack_phase_starting")
		connect("attackPhaseEnding", get_parent(), "on_attack_phase_ending")
		connect("enemyDead", get_parent(), "on_enemyDead")
func approach(): #stop attacking and slowly approach player
	$ApproachTimer.wait_time = approachTime * bulletTimeMultiplierNotZero
	$ApproachTimer.start()
	$enemyMovement/PathFollow2D/AnimatedSprite.play("moving")
	$enemyMovement/PathFollow2D/AnimatedSprite.scale.x = origScale
	$enemyMovement/PathFollow2D/AnimatedSprite.scale.y = origScale
	visible = true
	isAttackPhase = false 
	emit_signal("attackPhaseEnding")
func _physics_process(delta):
	if not isAttackPhase and bulletTimeMultiplier != 0: #increase scale (grow bigger each frame)
		$enemyMovement/PathFollow2D/AnimatedSprite.scale.x += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta 
		$enemyMovement/PathFollow2D/AnimatedSprite.scale.y += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta
	$HPBar.value = 1.0 * currentHP/maxHP * 100
func _on_ApproachTimer_timeout(): #when timer finishes, sprite is proper size
	isAttackPhase = true #stop growing
	emit_signal("attackPhaseStarting")
	$enemyMovement/PathFollow2D/AnimatedSprite.play("idle")
	startFight()
func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting


#FIGHT AND BULLET SPAWNING

func startFight():
	loopStart = attackPatternData[0]['loopStart'] #iterated through json file
	loopEnd = attackPatternData[0]['loopEnd']
	currAttack = loopStart
	attack()
	
func attack():
	#spawn bullet, place in proper position w proper speed 
	bullet = bulletScene.instance() 
	$BulletSpawnPath/bulletSpawnLocation.unit_offset = 1.0 * attackPatternData[currAttack]['spawnLocationX'] / 100
	bullet.position = $BulletSpawnPath/bulletSpawnLocation.position + $BulletSpawnPath.position
#	bullet.position.x = attackPatternData[currAttack]['spawnLocationX'] - position.x
#	bullet.position.y = $bulletSpawnLocationY.position.y
#	bullet.angle = attackPatternData[currAttack]['angle']
	bullet.speed *= bulletTimeMultiplier
	add_child(bullet)
	print(bullet.position.x, " ", bullet.position.y)
	currBullets += 1
	if currBullets <= bulletsPerAttackPhase:
		#get time before next bullet and start timer
		$bulletSpawnTimer.wait_time = attackPatternData[currAttack]['waitTime'] / abs(bulletTimeMultiplier) #time in between bullets spawning
		$bulletSpawnTimer.start()
		currAttack += 1
		if currAttack > loopEnd:
			currAttack = loopStart
	else:
		$bulletSpawnTimer.stop()
		currBullets = 0
		approach()
func _on_bulletSpawnTimer_timeout():
	attack()
	
#TIME FUNCTIONS

func reverseTime():
	bulletTimeMultiplier *= -1 
	$bulletSpawnTimer.paused = not $bulletSpawnTimer.paused
func speedUpTime(multiplier : float = 2):
	bulletTimeMultiplier = sign(bulletTimeMultiplier) * multiplier
func stopTime():
	bulletTimeMultiplierNotZero = bulletTimeMultiplier
	bulletTimeMultiplier = 0
	$bulletSpawnTimer.paused = true
	$ApproachTimer.paused = true
	$enemyMovement/PathFollow2D/AnimatedSprite.playing = false
	$enemyMovement.set_process(false)
func resumeTime():
	bulletTimeMultiplier = bulletTimeMultiplierNotZero
	$bulletSpawnTimer.paused = false
	$ApproachTimer.paused = false
	$enemyMovement/PathFollow2D/AnimatedSprite.playing = true
	$enemyMovement.set_process(true)
	
#TAKE DAMAGE

func getHit(damage:int):
	currentHP -= 1
	print("enemy HP = ", currentHP)
	if currentHP <= 0:
		$enemyMovement.set_process(false)
		$enemyMovement/PathFollow2D/AnimatedSprite.play("die")
		$DeathTimer.start() #leave time to play death animation before showing win screen
		get_tree().call_group("bulletTypes", "die")
func _on_DeathTimer_timeout():
	$bulletSpawnTimer.paused = true
	$ApproachTimer.paused = true
	emit_signal("enemyDead")
	Global.overWorldShouldDespawnEnemy = true
	queue_free()


#HELPER

func getAttackPatternData():
	attackPatternData = File.new() 
	if attackPatternData.file_exists(attackPatternFile): #get the attack pattern json file from the enemy node
		attackPatternData.open(attackPatternFile, attackPatternData.READ)
		return parse_json(attackPatternData.get_as_text())




