extends CharacterBody2D

@export var bulletScene : PackedScene #packed scene of the bullet this enemy uses
var bullet = null
@export var attackPatternFile #imported json file of music pattern # (String, FILE, "*.json")
@export var normalMusic : AudioStreamWAV
@export var reverseMusic : AudioStreamWAV
var origScale = 0.3 # starting size of sprite when enemy spawns
@export var finalScale = 1 #final size of the sprite once it has approached
@export var enemySpeed = 10 #speed at which the enemy wanders around
@export var maxHP = 5
var currentHP = maxHP
var currAttack = 1 #current line of json file
var currBullets = 0
var bulletsStopped = false
var bulletSpawnTimeCounter : float = 0 #using this instead of a timer node because I need it to be effected by the time shenanigans
enum {
	AWAY,
	APPROACHING,
	ATTACKING,
	ABSCONDING }
var currState = AWAY
@export var stateWaitTimes = [10, 100, 20, 2] # how long in seconds enemy stays in each state (approaching one not used, made it big so it never triggers)
var approachSpeed = 30
var approachVector = Vector2.ZERO
var stateCounter = 0 #used to count for a state according to above times and know when to switch

signal attackPhaseStarting
signal attackPhaseEnding
signal enemyDead
signal enemyMoved

#SETUP AND APPROACH

func _ready():
	$enemyMovement/PathFollow2D/AnimatedSprite2D.scale.x = origScale
	$enemyMovement/PathFollow2D/AnimatedSprite2D.scale.y = origScale
	$enemyMovement.enemySpeed = enemySpeed
	$enemyMovement/PathFollow2D/HPBar.value = 1.0 * currentHP/maxHP * 100

	Global.connect("timeMultiplierChanged", Callable(self, "changeAnimationSpeed"))
	Global.connect("timeFlowChanged", Callable(self, "startOrStopAnimation"))
	
	currState = AWAY
	startAwayPhase()
	visible = true
		
func _physics_process(delta):
	stateCounter += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int) * ((Global.currCombatTimeMultiplier > 0) as int) # only inc if time is moving AND time isnt reversed
	if stateCounter >= stateWaitTimes[currState]: #need to go to next state
		goToNextState()
	elif stateCounter <= 0: #time reversed, need to go to prev state
		goToPrevState()
	if currState == APPROACHING: #increase scale (grow bigger each frame)
		position += approachVector * delta * approachSpeed
		$enemyMovement/PathFollow2D/AnimatedSprite2D.scale.x += ((finalScale - origScale)/stateWaitTimes[APPROACHING]) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		$enemyMovement/PathFollow2D/AnimatedSprite2D.scale.y += ((finalScale - origScale)/stateWaitTimes[APPROACHING]) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	elif currState == ABSCONDING:
		$enemyMovement/PathFollow2D/AnimatedSprite2D.scale.x -= ((finalScale - origScale)/stateWaitTimes[ABSCONDING] ) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		$enemyMovement/PathFollow2D/AnimatedSprite2D.scale.y -= ((finalScale - origScale)/stateWaitTimes[ABSCONDING] ) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
func startAttackPhase():
	currState = ATTACKING
	$enemyMovement/PathFollow2D/AnimatedSprite2D.play("idle")
	$BulletSpawnPath.rotateBulletSpawnPath()
func startLeavePhase():
	currState = ABSCONDING
	$enemyMovement/PathFollow2D/AnimatedSprite2D.play("moving")
func startAwayPhase():
	currState = AWAY
	$enemyMovement/PathFollow2D/AnimatedSprite2D.play("idle")
	emit_signal("attackPhaseEnding")
func startApproachPhase(): 
	prevLocation = position
	findNewTile()
	emit_signal("enemyMoved")
	approachVector = Vector2(Global.getEnemyCoords().x - prevLocation.x, Global.getEnemyCoords().y - prevLocation.y).normalized()
	stateWaitTimes[APPROACHING] = (prevLocation.distance_to(Global.getEnemyCoords()) / approachSpeed ) + 0.1
	if stateWaitTimes[APPROACHING] < 0.5: #if enemy is not moving. fixes weird bugs as things are divided by tiny floats and looks jank
		approachVector = Vector2.ZERO
		stateWaitTimes[APPROACHING] = 1
	currState = APPROACHING
	$enemyMovement/PathFollow2D/AnimatedSprite2D.play("moving")
	emit_signal("attackPhaseStarting")


func goToNextState():
	stateCounter = 0
	if currState == AWAY:
		startApproachPhase()
	elif currState == APPROACHING:
		startAttackPhase()
	elif currState == ATTACKING:
		startLeavePhase()
	else:
		startAwayPhase()

func goToPrevState():
	if currState == AWAY:
		startLeavePhase()
	elif currState == APPROACHING:
		startAwayPhase()
	elif currState == ATTACKING:
		startApproachPhase()
	else:
		startAttackPhase()
	stateCounter = stateWaitTimes[currState]

func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting


#FIGHT AND BULLET SPAWNING

var gridSizeByBulletPathPerc = 17
func attack(musicNotePitch):
	
	if not bulletsStopped and currState == ATTACKING:
		$BulletSpawnPath.spawnBullet(50 + musicNotePitch * gridSizeByBulletPathPerc, 0)
	
func changeAnimationSpeed(): #called whenever the global time variable is changed, ugly but i cant find a better way
	$enemyMovement/PathFollow2D/AnimatedSprite2D.set_speed_scale(abs(Global.currCombatTimeMultiplier))
	if Global.currCombatTimeMultiplier < 0:
		$enemyMovement/PathFollow2D/HurtBox/CollisionShape2D.set_deferred("disabled", false)
		$enemyMovement/PathFollow2D/HitBox/CollisionShape2D.set_deferred("disabled", false)
		if Global.timeIsNotStopped:
			$enemyMovement/PathFollow2D/AnimatedSprite2D.play($enemyMovement/PathFollow2D/AnimatedSprite2D.animation, true)
	else:
		$enemyMovement/PathFollow2D/HurtBox/CollisionShape2D.set_deferred("disabled", true)
		$enemyMovement/PathFollow2D/HitBox/CollisionShape2D.set_deferred("disabled", true)
func startOrStopAnimation():
	if Global.timeIsNotStopped:
		$enemyMovement/PathFollow2D/AnimatedSprite2D.play($enemyMovement/PathFollow2D/AnimatedSprite2D.animation, Global.currCombatTimeMultiplier < 0)
	else:
		$enemyMovement/PathFollow2D/AnimatedSprite2D.stop()

func playerDie():
	bulletsStopped = true
	set_physics_process(false)
	

#TAKE DAMAGE

func getHit(damage:int):
	currentHP -= 1 * abs(Global.currCombatTimeMultiplier)
	$enemyMovement/PathFollow2D/HPBar.value = 1.0 * currentHP/maxHP * 100
	if currentHP <= 0:
		set_process(false)
		$enemyMovement.set_process(false)
		$enemyMovement/PathFollow2D/AnimatedSprite2D.play("die")
		$DeathTimer.start() #leave time to play death animation before showing win screen
		get_tree().call_group("bulletTypes", "die")
func _on_DeathTimer_timeout():
	emit_signal("enemyDead")
	Global.updateDeadEnemyList(Global.overWorldDeadEnemiesList)
	queue_free()



#GRID MOVEMENT
var playerGridSquare = Vector2(2, 2)
var currentGridSquare = Vector2(2, 1)
var prevLocation = Vector2.ZERO
var bigGridLocationsx = [18, 90, 160, 230, 300 ]
var bigGridLocationsy = [-30, 40, 110, 180, 250]


func findNewTile(): #finds closest valid tile near the player to move to
	var squareAbove = (Global.playerGridLocation + Vector2(0, -1))
	var squareBelow = (Global.playerGridLocation + Vector2(0, 1))
	var squareLeft = (Global.playerGridLocation + Vector2(-1, 0))
	var squareRight = (Global.playerGridLocation + Vector2(1, 0))
	var closestSquare = squareAbove
	
	if calculateTileDistance(closestSquare) > calculateTileDistance(squareBelow):
		closestSquare = squareBelow
	if calculateTileDistance(closestSquare) > calculateTileDistance(squareRight):
		closestSquare = squareRight
	if calculateTileDistance(closestSquare) > calculateTileDistance(squareLeft):
		closestSquare = squareLeft
	
	Global.enemyGridLocation = closestSquare
		
func calculateTileDistance(playerAdjacentTile : Vector2):
	if playerAdjacentTile.x < 0 or playerAdjacentTile.x > 4 or playerAdjacentTile.y < 0 or playerAdjacentTile.y > 4: 
		return 10000 #impossible tile to reach, impossibly big number so it wont go there
	else: 
		return abs(Global.enemyGridLocation.x - playerAdjacentTile.x) + abs(Global.enemyGridLocation.y - playerAdjacentTile.y)
	



