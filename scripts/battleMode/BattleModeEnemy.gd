extends KinematicBody2D

export var bulletScene : PackedScene #packed scene of the bullet this enemy uses
var bullet = null
export var approachTime = 9 # how long in seconds enemy takes to approach
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
var bulletsPerAttackPhase = 10 #how many bullets they spawn during each attack phase before approaching again
var currAttack = 1 #current line of json file
var currBullets = 0
var bulletTimeMultiplier : float = 1 #always multiplied onto bullets speed when they are spawned, when time is reversed, this is changed to -1
var bulletTimeMultiplierNotZero : float = 1 # storage variable for bullet speed when resuming time
var bulletSpawnTimeCounter : float = 0 #using this instead of a timer node because I need it to be effected by the time shenanigans
var animationSpeedStorage = []

signal attackPhaseStarting
signal attackPhaseEnding
signal enemyDead

#SETUP AND APPROACH

func _ready():
	$enemyMovement.enemySpeed = enemySpeed
	attackPatternData = getAttackPatternData() #get the json file and get it as a string
	loopStart = attackPatternData[0]['loopStart'] #iterated through json file
	loopEnd = attackPatternData[0]['loopEnd']
	bulletSpawnTimeCounter = attackPatternData[loopStart]['waitTime']
	if get_parent():
		connect("attackPhaseStarting", get_parent(), "on_attack_phase_starting")
		connect("attackPhaseEnding", get_parent(), "on_attack_phase_ending")
		connect("enemyDead", get_parent(), "on_enemyDead")
		Global.connect("timeMultiplierChanged", self, "changeAnimationSpeed")
		Global.connect("timeFlowChanged", self, "startOrStopAnimation")
	
		
func approach(): #stop attacking and slowly approach player
	$enemyMovement/PathFollow2D/AnimatedSprite.play("moving")
	$enemyMovement/PathFollow2D/AnimatedSprite.scale.x = origScale
	$enemyMovement/PathFollow2D/AnimatedSprite.scale.y = origScale
	visible = true
	isAttackPhase = false 
	emit_signal("attackPhaseEnding")
func _physics_process(delta):
#	$enemyMovement/PathFollow2D/AnimatedSprite.speed_scale = $enemyMovement/PathFollow2D/AnimatedSprite
	if not isAttackPhase: #increase scale (grow bigger each frame)
		$enemyMovement/PathFollow2D/AnimatedSprite.scale.x += ((finalScale - origScale)/approachTime) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		$enemyMovement/PathFollow2D/AnimatedSprite.scale.y += ((finalScale - origScale)/approachTime) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		if $enemyMovement/PathFollow2D/AnimatedSprite.scale.x >= finalScale: #when sprite reaches proper size
			startAttackPhase()
	else:
		bulletSpawnTimeCounter -= delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		if bulletSpawnTimeCounter <= 0:
			attack()
func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting


#FIGHT AND BULLET SPAWNING

func startAttackPhase():
	isAttackPhase = true #stop growing
	emit_signal("attackPhaseStarting")
	$enemyMovement/PathFollow2D/AnimatedSprite.play("idle")
	currBullets = 0
	currAttack = loopStart
	attack()
	
func attack():
	#spawn bullet, place in proper position w proper speed 
	bullet = bulletScene.instance() 
	$BulletSpawnPath/bulletSpawnLocation.unit_offset = 1.0 * attackPatternData[currAttack]['spawnLocationX'] / 100
	bullet.position = $BulletSpawnPath/bulletSpawnLocation.position + $BulletSpawnPath.position #global_position??
	bullet.angle = attackPatternData[currAttack]['angle']
	add_child(bullet)
	currBullets += 1
	if currBullets <= bulletsPerAttackPhase:
		#get time before next bullet and start timer
		bulletSpawnTimeCounter = attackPatternData[currAttack]['waitTime'] #time in between bullets spawning
		currAttack += 1
		if currAttack > loopEnd:
			currAttack = loopStart
	else:
		approach()
		
func changeAnimationSpeed(): #called whenever the global time variable is changed, ugly but i cant find a better way
	$enemyMovement/PathFollow2D/AnimatedSprite.set_speed_scale(abs(Global.currCombatTimeMultiplier))
	if Global.currCombatTimeMultiplier < 0 and Global.timeIsNotStopped:
		$enemyMovement/PathFollow2D/AnimatedSprite.play($enemyMovement/PathFollow2D/AnimatedSprite.animation, true)
func startOrStopAnimation():
	if Global.timeIsNotStopped:
		$enemyMovement/PathFollow2D/AnimatedSprite.play($enemyMovement/PathFollow2D/AnimatedSprite.animation, Global.currCombatTimeMultiplier < 0)
	else:
		$enemyMovement/PathFollow2D/AnimatedSprite.stop()


#TAKE DAMAGE

func getHit(damage:int):
	currentHP -= 1
	$HPBar.value = 1.0 * currentHP/maxHP * 100
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




