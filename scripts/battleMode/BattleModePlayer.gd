extends KinematicBody2D



export var smallGridSize = 20
var currGridSize = 20
var velocity = Vector2.ZERO
var storagePos = Vector2.ZERO #used as storage during input calculations for jumping
export var maxHP : int = 20
export var currentHP : int = maxHP
export var invincible : bool = true #for debugging #only works if you dont move
enum {
	DEFENSE
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

# player script mostly deals with movement and animation, all other input is handled by BattleMode.gd



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
	storagePos = position
	
	if invincible:
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
	
# DEFENSE MODE MOVEMENT
	
func _process(delta):
	if $inputTimer.time_left > 0: #if mid jump (defense mode)
		position.x += (storagePos.x - position.x)/$inputTimer.time_left * delta
		position.y += (storagePos.y - position.y)/$inputTimer.time_left * delta
		if abs(storagePos.x - position.x) >= abs(storagePos.y - position.y):
			$Animations.animation = "ball horizontal"
			$Animations.flip_h = storagePos.x < position.x
		else:
			$Animations.animation = "ball vertical"
			$Animations.flip_v = storagePos.y < position.y
	elif currState == MOVINGTILES:
		position +=( Global.getPlayerCoords() - prevLocation) / $Animations/moveTilesTimer.wait_time * delta

func _input(event):
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
	elif currState == DEFENSE:
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
	$HurtBox/CollisionShape2D.disabled = false
	$HitBox/CollisionShape2D.disabled = false

# GET HIT 	

func getHit(damage:int):
	if isShielded:
		isShielded = false
		$Shield.visible = false
		return
	currentHP -= 1 * abs(Global.currCombatTimeMultiplier)
	emit_signal("PlayerHit")
	if currentHP <= 0:
		die()
func die():
	set_process_input(false)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	emit_signal("PlayerDie")
	$Animations.play("die")

# OFFENSE MODE (called by BattleMode.gd)

func _on_BattleMode_offensePhaseEnding():
	currState = DEFENSE
	position = Global.getPlayerCoords() #snap to correct grid location (shouldnt be able to see the sudden movement bc grid is hidden)
	storagePos = position
	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key
		storagePos.x += currGridSize
	if Input.get_action_strength("ui_left") > 0:
		storagePos.x -= currGridSize
	if Input.get_action_strength("ui_up") > 0:
		storagePos.y -= currGridSize
	if Input.get_action_strength("ui_down") > 0:
		storagePos.y += currGridSize
func _on_BattleMode_offensePhaseStarting():
	position = Global.getPlayerCoords()
	currState = IDLE
func startWindWatch():
	if isShielded:
		return
	$Animations.play("wind watch")
func finishWindWatch():
	if isShielded: 
		return false #return whether it actually happended
	$Animations.play("idle")
	return true
func startHeal():
	if isShielded:
		return
	$Animations.play("wind watch")
func finishHeal(hpHealed : int):
	if isShielded:
		return
	currentHP += hpHealed
	if currentHP > maxHP:
		currentHP = maxHP
	emit_signal("PlayerHit") #update HP bar in parent node
	$Animations.play("idle")
func startAttack(damage : int):
	if isShielded:
		return
	get_tree().call_group("enemies", "getHit", damage)
func finishAttack():
	pass
func shield():
	$Shield.visible = true
	isShielded = true
func move(direction):
	if currState != MOVINGTILES and Global.canMoveTo(Global.playerGridLocation + moveVectors[direction]):
		moveDirection = direction
		prevLocation = position
		updateCurrGridSquare()
		$Animations/moveTilesTimer.start()
		currState = MOVINGTILES
		$Animations.play(moveAnimations[direction])
		emit_signal("playerMovedOffense", direction, Global.playerGridLocation, $Animations/moveTilesTimer.wait_time)
func updateCurrGridSquare():
	Global.setPlayerGridLocation(Global.playerGridLocation + moveVectors[moveDirection])
func _on_moveTilesTimer_timeout():
	emit_signal("playerFinishedMoving", Global.playerGridLocation)
	$Animations.play("idle")
	if currState == DEFENSE:
		return
	currState = IDLE
	storagePos = position
