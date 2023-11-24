extends KinematicBody2D



export var smallGridSize = 20
var currGridSize = 20
var velocity = Vector2.ZERO
var storagePos = Vector2.ZERO #used as storage during input calculations for jumping
export var maxHP : int = 20
export var currentHP : int = maxHP
export var invincible : bool = true #for debugging #only works if you dont move
enum {
	DEFENSE #small grid dodging
	IMOBILE # ex. while winding watch
	MOVINGTILES # moving around the big tiles
	IDLE # normal state during offense
}
var isShielded = false
var currState = DEFENSE
enum { RIGHT, LEFT, UP, DOWN }
var moveDirection = RIGHT
var moveVectors : PoolVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]
var moveAnimations = ["move right", "move left", "move up", "move down"]
var tileMoveSpeed = 50
var bigGridLocationsx = [18, 90, 160, 230, 300 ]
var bigGridLocationsy = [-30, 40, 110, 180, 250]
var prevLocation = Vector2.ZERO

signal PlayerHit
signal PlayerDie
signal playerMovedOffense(direction, newTile, timeToMoveThere)
signal playerFinishedMoving(newTile)

# player script mostly deals with movement and animation, all other input is handled by BattleMode.gd and actionmenu



func _ready():
	$Animations.play("idle")
	currGridSize = $rightGridLocation.position.x
#	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key when entering battle mode
#		position.x += currGridSize
#	if Input.get_action_strength("ui_left") > 0:
#		position.x -= currGridSize
#	if Input.get_action_strength("ui_up") > 0:
#		position.y -= currGridSize
#	if Input.get_action_strength("ui_down") > 0:
#		position.y += currGridSize
	storagePos = Global.getPlayerCoords()
	
	if invincible:
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
	
# DEFENSE MODE MOVEMENT
	
func _process(delta):
	if $inputTimer.time_left > 0: #if mid jump (defense mode)
		position.x += (storagePos.x - position.x)/$inputTimer.time_left * delta
		position.y += (storagePos.y - position.y)/$inputTimer.time_left * delta
		position.x = clamp(position.x, Global.getPlayerCoords().x - currGridSize, Global.getPlayerCoords().x + currGridSize)
		position.y = clamp(position.y, Global.getPlayerCoords().y - currGridSize, Global.getPlayerCoords().y + currGridSize)
		if abs(storagePos.x - position.x) >= abs(storagePos.y - position.y):
			if storagePos.x - position.x > 0: $Animations.play("jump right")
			else:$Animations.play("jump left")
		else:
			if storagePos.y - position.y > 0: $Animations.play("jump down")
			else:$Animations.play("jump up")
	elif currState == MOVINGTILES:
		position +=( Global.getPlayerCoords() - prevLocation) / $Animations/moveTilesTimer.wait_time * delta

func _input(event): #this is movement only. no actions
	if not Global.timeIsNotStopped: return
	if(event.is_action_pressed("ui_up")):
		if currState == DEFENSE:
			handleInput()
			storagePos.y -= currGridSize
		elif currState == IDLE:
			move(UP)
	elif(event.is_action_pressed("ui_down")):
		if currState == DEFENSE:
			handleInput()
			storagePos.y += currGridSize
		elif currState == IDLE:
			move(DOWN)
	elif(event.is_action_pressed("ui_right")):
		if currState == DEFENSE:
			handleInput()
			storagePos.x += currGridSize
		elif currState == IDLE:
			move(RIGHT)
	elif(event.is_action_pressed("ui_left")):
		if currState == DEFENSE:
			handleInput()
			storagePos.x -= currGridSize
		elif currState == IDLE:
			move(LEFT)
	elif currState == DEFENSE: #release buttons
		if(event.is_action_released("ui_up")):
			handleInput()
			storagePos.y += currGridSize
		elif(event.is_action_released("ui_down")):
			handleInput()
			storagePos.y -= currGridSize
		elif(event.is_action_released("ui_right")):
			handleInput()
			storagePos.x -= currGridSize
		elif(event.is_action_released("ui_left")):
			handleInput()
			storagePos.x += currGridSize		
func handleInput():
	if $inputTimer.time_left == 0:
		$HurtBox/CollisionShape2D.disabled = true
		$HitBox/CollisionShape2D.disabled = true
		$inputTimer.start()
func _on_inputTimer_timeout():
	position = storagePos
	$Animations.flip_v = false
	$Animations.play("land")
	if currState == DEFENSE:
		$HurtBox/CollisionShape2D.disabled = false
		$HitBox/CollisionShape2D.disabled = false

# GET HIT 	

func getHit(damage:int):
	if isShielded: # if sheilded, dont hit
		isShielded = false
		$Shield.play("hit")
		$hitSheildSFX.play(0.05)
		return
	
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$damageCooldownTimer.start()
	$Animations.playHurtAnimation()
	currentHP -= damage * abs(Global.currCombatTimeMultiplier)
	$hitSFX.play(0.0)
	emit_signal("PlayerHit")
	if currentHP <= 0:
		die()
		
func _on_damageCooldownTimer_timeout():
	$HurtBox/CollisionShape2D.set_deferred("disabled", false)
	$HitBox/CollisionShape2D.set_deferred("disabled", false)

func die():
	set_process_input(false)
	$damageCooldownTimer.stop()
	$Animations._on_damageCooldownTimer_timeout()
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$dieSFX.play(0.0)
	emit_signal("PlayerDie")
	$Animations.play("die")

# OFFENSE MODE (called by BattleMode.gd)

func _on_BattleMode_enemyApproachPhaseStarting(_duration): #disable movingtiles, but should be able to finish current tile movement
	if currState != MOVINGTILES: currState = IDLE
	$debugLabel.text = currState as String
	movingTilesDisabled = true
func _on_BattleMode_offensePhaseEnding(_duration): #anglechange phase
	currState = DEFENSE
	$debugLabel.text = currState as String
	storagePos = Global.getPlayerCoords()
#	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key
#		storagePos.x += currGridSize
#	if Input.get_action_strength("ui_left") > 0:
#		storagePos.x -= currGridSize
#	if Input.get_action_strength("ui_up") > 0:
#		storagePos.y -= currGridSize
#	if Input.get_action_strength("ui_down") > 0:
#		storagePos.y += currGridSize
	if Global.currCombatTimeMultiplier > 0:
		checkForKeyPresses()
	else:
		forcePlayerToMiddle()
	$Animations.play("idle")
func _on_BattleMode_enemyAttackPhaseStarting(_duration):
	currState = DEFENSE
	$debugLabel.text = currState as String
func _on_BattleMode_enemyAbscondPhaseStarting(_duration):
	currState = IDLE
	$debugLabel.text = currState as String
	# forces player character to move to the center of the grid as if they jumped there
#	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key
#		storagePos.x -= currGridSize
#	if Input.get_action_strength("ui_left") > 0:
#		storagePos.x += currGridSize
#	if Input.get_action_strength("ui_up") > 0:
#		storagePos.y += currGridSize
#	if Input.get_action_strength("ui_down") > 0:
#		storagePos.y -= currGridSize
	if Global.currCombatTimeMultiplier > 0:
		forcePlayerToMiddle()
	else:
		checkForKeyPresses()
	$HurtBox/CollisionShape2D.disabled = true 
	$HitBox/CollisionShape2D.disabled = true
	$inputTimer.start()
func _on_BattleMode_offensePhaseStarting(_duration): #away phase starting
	currState = IDLE
	$debugLabel.text = currState as String
	$HurtBox/CollisionShape2D.disabled = false 
	$HitBox/CollisionShape2D.disabled = false
	movingTilesDisabled = false
	position = Global.getPlayerCoords()
	

func finishAttack():
	pass
var movingTilesDisabled = false
func move(direction):
	if currState != MOVINGTILES and Global.canMoveTo(Global.playerGridLocation + moveVectors[direction]) and not miniGameActive and not movingTilesDisabled:
		moveDirection = direction
		prevLocation = position
		updateCurrGridSquare()
		$Animations/moveTilesTimer.start()
		currState = MOVINGTILES
		$debugLabel.text = currState as String
		$Animations.play(moveAnimations[direction])
		emit_signal("playerMovedOffense", direction, Global.playerGridLocation, $Animations/moveTilesTimer.wait_time)
func updateCurrGridSquare():
	Global.setPlayerGridLocation(Global.playerGridLocation + moveVectors[moveDirection])
func _on_moveTilesTimer_timeout():
	position = Global.getPlayerCoords()
	emit_signal("playerFinishedMoving", Global.playerGridLocation)
	$Animations.play("idle")
#	if miniGameActive:
#		$Animations.play("wind watch")
	if currState == DEFENSE:
		return
	currState = IDLE
	$debugLabel.text = currState as String
	storagePos = Global.getPlayerCoords()
func checkForKeyPresses(reverse : int = 1): # for going from a locked in place phase (angle change or abscond) to enemy attacking
	if reverse != 1 and reverse != -1:
		print("ERROR: arguments should be 1 or -1 only")
		return
	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key
		storagePos.x += currGridSize * reverse
	if Input.get_action_strength("ui_left") > 0:
		storagePos.x -= currGridSize * reverse
	if Input.get_action_strength("ui_up") > 0:
		storagePos.y -= currGridSize * reverse
	if Input.get_action_strength("ui_down") > 0:
		storagePos.y += currGridSize * reverse
func forcePlayerToMiddle(): # for going from attacking to a locked in place phase
	checkForKeyPresses(-1)
	handleInput()

# MINIGAMES
var miniGameActive = false
func _on_UI_minigameActiveUpdate(active):
	miniGameActive = active

func _on_UI_sheildActivated(activated, _delaySeconds):
	movingTilesDisabled = true
	isShielded = activated
	if activated:
		$Shield.play("activated")
		$equipSheildSFX.play(0.15)
	else:
		$Shield.play("deactivate")
		$unequipSheildSFX.play(0.15)
		$Animations.frame = 0
		$Animations.play("unsheild")
func _on_UI_sheildDeactivationComplete():
	movingTilesDisabled = false


func _on_UI_caughtHeal(HPHealed):
	currentHP += HPHealed
	if currentHP > maxHP:
		currentHP = maxHP
	emit_signal("PlayerHit") #update HP bar in parent node


#minigame animations
func _on_UI_winding(activated):
	pass # Replace with function body.
func _on_UI_attacking(activated):
	pass # Replace with function body.
func _on_UI_healing(activated):
	pass # Replace with function body.


