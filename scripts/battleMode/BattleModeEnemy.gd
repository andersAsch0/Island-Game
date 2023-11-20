extends KinematicBody2D

export var bulletScene : PackedScene #packed scene of the bullet this enemy uses
var bullet = null
export(String, FILE, "*.json") var attackPatternFile #imported json file
export var normalMusic : AudioStreamSample
export var reverseMusic : AudioStreamSample
var origScale = 0.9 # starting size of sprite when enemy spawns
export var finalScale = 1 #final size of the sprite once it has approached
export var enemySpeed = 30 #speed at which the enemy wanders around
export var maxHP = 5
var currentHP = maxHP
var currAttack = 1 #current line of json file
var currBullets = 0
var bulletsStopped = false
enum {
	AWAY
	APPROACHING
	ANGLECHANGE
	ATTACKING
	ABSCONDING
}
var currState = APPROACHING
export var stateWaitTimes = [10.0, 10.0, 0.8, 5, 0.8] # how long in seconds enemy stays in each state (approaching one not used, made it big so it never triggers)
var approachSpeed = 30
var approachVector = Vector2.ZERO
var stateCounter = 0 #used to count for a state according to above times and know when to switch
onready var animatedSpriteNode = $enemyMovement/PathFollow2D/TimeSyncedAnimatedSprite
signal awayPhaseStarting(duration)
signal approachPhaseStarting(duration)
signal angleChangePhaseStarting(duration)
signal attackPhaseStarting(duration)
signal abscondPhaseStarting(duration)

signal attackPhaseEnding
signal enemyDead
signal enemyMoved

#SETUP AND APPROACH

func _ready():
	animatedSpriteNode.scale.x = origScale
	animatedSpriteNode.scale.y = origScale
	$enemyMovement.enemySpeed = enemySpeed
	updateHPBar()
	
	currState = AWAY
	startAwayPhase()
	visible = true
		
func _physics_process(delta):
	stateCounter += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int) # only inc if time is moving
	if stateCounter >= stateWaitTimes[currState]: #need to go to next state
		goToNextState()
		print("enemy state : ", getEnemyCurrState())
	elif stateCounter <= 0: #time reversed, need to go to prev state
		goToPrevState()
		print("enemy state : ", getEnemyCurrState())
	
	#frame by frame animation and movement
	if currState == APPROACHING:
		position += approachVector * delta * approachSpeed * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		animatedSpriteNode.scale.x += ((finalScale - origScale)/stateWaitTimes[APPROACHING]) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		animatedSpriteNode.scale.y += ((finalScale - origScale)/stateWaitTimes[APPROACHING]) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	elif currState == ANGLECHANGE:
		position += (angleChangeVector / stateWaitTimes[ANGLECHANGE] ) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	elif currState == ABSCONDING:
		animatedSpriteNode.scale.x -= ((finalScale - origScale)/stateWaitTimes[ABSCONDING] ) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		animatedSpriteNode.scale.y -= ((finalScale - origScale)/stateWaitTimes[ABSCONDING] ) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		position -= (angleChangeVector / stateWaitTimes[ABSCONDING]) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	
	$PlayerHPBar2.value = stateCounter / stateWaitTimes[currState] * 100
func startAttackPhase():
	currState = ATTACKING
	animatedSpriteNode.play("idle")
	emit_signal("attackPhaseStarting", stateWaitTimes[ATTACKING])
func startLeavePhase():
	currState = ABSCONDING
	animatedSpriteNode.play("moving")
	emit_signal("abscondPhaseStarting", stateWaitTimes[ABSCONDING])
func startAwayPhase():
	animatedSpriteNode.scale.x = origScale
	animatedSpriteNode.scale.y = origScale
	currState = AWAY
	animatedSpriteNode.play("idle")
	emit_signal("attackPhaseEnding")
	emit_signal("awayPhaseStarting", stateWaitTimes[AWAY])
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
	animatedSpriteNode.play("moving")
	emit_signal("approachPhaseStarting", stateWaitTimes[APPROACHING])
var angleChangeVector = Vector2()
func startAnglechangePhase():
#	animatedSpriteNode.scale.x = finalScale
#	animatedSpriteNode.scale.y = finalScale
	var enemyDiscplacement = Global.getEnemyDisplacementFromPlayer()
	if enemyDiscplacement.x == 0:
		angleChangeVector = Vector2(0,(69 - abs(Global.getPlayerCoords().y - Global.getEnemyCoords().y))*sign(Global.getPlayerCoords().y - Global.getEnemyCoords().y) * -1)
	else:
		angleChangeVector = Vector2((69 - abs(Global.getPlayerCoords().x - Global.getEnemyCoords().x))*sign(Global.getPlayerCoords().x - Global.getEnemyCoords().x) * -1, 0)
	currState = ANGLECHANGE
	emit_signal("angleChangePhaseStarting", stateWaitTimes[ANGLECHANGE])

func goToNextState():
	stateCounter = 0
	if currState == AWAY:
		startApproachPhase()
	elif currState == APPROACHING:
		startAnglechangePhase()
	elif currState == ANGLECHANGE:
		startAttackPhase()
	elif currState == ATTACKING:
		startLeavePhase()
	else: #currstate == absconding
		startAwayPhase()
	$Label/Label.text = (currState as String)

func goToPrevState():
	if currState == AWAY:
		startLeavePhase()
	elif currState == APPROACHING:
		startAwayPhase()
	elif currState == ANGLECHANGE:
		startApproachPhase()
	elif currState == ATTACKING:
		startAnglechangePhase()
	else: # currstate == absconding
		startAttackPhase()
	stateCounter = stateWaitTimes[currState]
	$Label/Label.text = (currState as String)

func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting


#FIGHT AND BULLET SPAWNING

var gridSizeByBulletPathPerc = 17
func playerDie():
	bulletsStopped = true
	set_physics_process(false)
	

#TAKE DAMAGE

func getHit(damage:int):
	currentHP -= damage * abs(Global.currCombatTimeMultiplier)
	updateHPBar()
	if currentHP <= 0:
		set_process(false)
		$enemyMovement.set_process(false)
		$enemyMovement/PathFollow2D/TimeSyncedAnimatedSprite.play("die")
		$DeathTimer.start() #leave time to play death animation before showing win screen
		get_tree().call_group("bulletTypes", "die")
		return
	if currState == AWAY:
		stateCounter = stateWaitTimes[AWAY] #being attacked triggers enemy to approach again
func _on_DeathTimer_timeout():
	emit_signal("enemyDead")
	queue_free()
func updateHPBar():
	$enemyMovement/PathFollow2D/HPBar.value = 1.0 * currentHP/maxHP * 100

#GRID MOVEMENT
var playerGridSquare = Vector2(2, 2)
var currentGridSquare = Vector2(2, 1)
var prevLocation = Vector2.ZERO
var bigGridLocationsx = [18, 90, 160, 230, 300 ]
var bigGridLocationsy = [-30, 40, 110, 180, 250]


func findNewTile(): #finds closest valid tile near the player to move to
	var squareAbove = (Global.playerGridLocation + Vector2(0, -1))
	var squareLeft = (Global.playerGridLocation + Vector2(-1, 0))
	var squareRight = (Global.playerGridLocation + Vector2(1, 0))
	var closestSquare = squareAbove
	
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

func getEnemyCurrState()-> String:
	if currState == AWAY: return "away"
	elif currState == APPROACHING: return "approaching"
	elif currState == ANGLECHANGE: return "angle change 3d to 2d"
	elif currState == ATTACKING: return "attacking"	
	elif currState == ABSCONDING: return "absconding (2d to 3d)"
	else: return "error state"
	
