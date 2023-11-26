extends KinematicBody2D



export var smallGridSize = 20
var currGridSize = 20
var velocity = Vector2.ZERO
var storagePos = Vector2.ZERO #used as storage during input calculations for jumping
export var maxHP : int = 20
export var currentHP : int = maxHP
export var invincible : bool = true #for debugging #only works if you dont move
enum { #what kind of movement is allowed
	DEFENSE #small grid dodging
	IMOBILE #cant move in any way, ex. while winding watch, anglechangephase, time is paused on defense?
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
	elif $Animations/moveTilesTimer.time_left > 0:
		position +=( Global.getPlayerCoords() - prevLocation) / $Animations/moveTilesTimer.wait_time * delta

func _input(event): #this is movement only. no actions
	if not (event.is_action_pressed("battleMovement") or event.is_action_released("battleMovement")): return
	if currState == DEFENSE:
		if(event.is_action_pressed("ui_up")): 
			handleInput()
			storagePos.y -= currGridSize
		elif(event.is_action_pressed("ui_down")):
			handleInput()
			storagePos.y += currGridSize
		elif(event.is_action_pressed("ui_right")):
			handleInput()
			storagePos.x += currGridSize
		elif(event.is_action_pressed("ui_left")):
			handleInput()
			storagePos.x -= currGridSize
		elif(event.is_action_released("ui_up")): #release buttons
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
	elif currState == IDLE:
		if(event.is_action_pressed("ui_up")): 
			move(UP)
		elif(event.is_action_pressed("ui_down")):
			move(DOWN)
		elif(event.is_action_pressed("ui_right")):
			move(RIGHT)
		elif(event.is_action_pressed("ui_left")):
			move(LEFT)
		
func handleInput(): #if timer is not already going, start it
	if $inputTimer.time_left == 0:
		$HurtBox/CollisionShape2D.disabled = true
		$HitBox/CollisionShape2D.disabled = true
		$inputTimer.start($inputTimer.wait_time)
func _on_inputTimer_timeout():
	position = storagePos
	$Animations.flip_v = false
	$Animations.play("land")
	if currState == DEFENSE:
		$HurtBox/CollisionShape2D.disabled = false
		$HitBox/CollisionShape2D.disabled = false
func cutOffInputTimer():
	$inputTimer.stop()
	_on_inputTimer_timeout()

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

func _on_BattleMode_enemyApproachPhaseStarting(_duration): #disable movingtiles, but should be able to finish current tile movement #1
	currState = IMOBILE
	$debugLabel.text = currState as String
	movingTilesDisabled = true
func _on_BattleMode_offensePhaseEnding(_duration): #anglechange phase #2
	currState = IMOBILE
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
	if Global.currCombatTimeMultiplier < 0:
		forcePlayerToMiddle()
	cutOffInputTimer()
	$Animations.play("idle")
func _on_BattleMode_enemyAttackPhaseStarting(_duration): #3
	checkForKeyPresses()
	currState = DEFENSE
	$HurtBox/CollisionShape2D.disabled = false
	$HitBox/CollisionShape2D.disabled = false
	$debugLabel.text = currState as String
func _on_BattleMode_enemyAbscondPhaseStarting(_duration):
	currState = IMOBILE
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
	cutOffInputTimer()
	if Global.currCombatTimeMultiplier > 0:
		forcePlayerToMiddle()
	$HurtBox/CollisionShape2D.disabled = true 
	$HitBox/CollisionShape2D.disabled = true
func _on_BattleMode_offensePhaseStarting(_duration): #away phase starting #0
	currState = IDLE
	$debugLabel.text = currState as String
	$HurtBox/CollisionShape2D.disabled = false 
	$HitBox/CollisionShape2D.disabled = false
	movingTilesDisabled = false
	position = Global.getPlayerCoords()
	

func finishAttack():
	pass
var movingTilesDisabled = false #when sheild is active?
func move(direction):
	if $Animations/moveTilesTimer.time_left == 0 and Global.canMoveTo(Global.playerGridLocation + moveVectors[direction]) and not miniGameActive and not isShielded:
		moveDirection = direction
		prevLocation = position
		updateCurrGridSquare()
		$Animations/moveTilesTimer.start()
		$debugLabel.text = currState as String
		$Animations.play(moveAnimations[direction])
		emit_signal("playerMovedOffense", direction, Global.playerGridLocation, $Animations/moveTilesTimer.wait_time)
func updateCurrGridSquare():
	Global.setPlayerGridLocation(Global.playerGridLocation + moveVectors[moveDirection])
func _on_moveTilesTimer_timeout():
	position = Global.getPlayerCoords()
	emit_signal("playerFinishedMoving", Global.playerGridLocation)
	$Animations.play("idle")
	$debugLabel.text = currState as String
	storagePos = Global.getPlayerCoords()
func checkForKeyPresses(): # for going from a locked in place phase (angle change or abscond) to enemy attacking
	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key
		storagePos.x += currGridSize
	if Input.get_action_strength("ui_left") > 0:
		storagePos.x -= currGridSize
	if Input.get_action_strength("ui_up") > 0:
		storagePos.y -= currGridSize
	if Input.get_action_strength("ui_down") > 0:
		storagePos.y += currGridSize
func forcePlayerToMiddle(): # for going from attacking to a locked in place phase
	storagePos = Global.getPlayerCoords()
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


