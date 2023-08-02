extends KinematicBody2D



export var smallGridSize = 20
export var bigGridSize = 30
var currGridSize = 20
var velocity = Vector2.ZERO
var storagePos = Vector2.ZERO #used as storage during input calculations for jumping
export var maxHP : int = 4
export var currentHP : int = maxHP
export var invincible : bool = true #for debugging #only works if you dont move
enum {
	DEFENSE
	IMOBILE # ex. while winding watch
	MOVINGTILES # moving around the big tiles
}
var currState = DEFENSE
enum { RIGHT, LEFT, UP, DOWN }
var moveDirection = RIGHT
var moveVectors : PoolVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]
var moveAnimations = ["move right", "move left", "move up", "move down"]
var tileMoveSpeed = 50
var bigGridLocationsx = [18, 90, 160, 230, 300 ]
var bigGridLocationsy = [-30, 40, 110, 180, 250]
var currentGridSquare = Vector2(2,2)

signal PlayerHit

# player script mostly deals with movement and animation, all other input is handled by BattleMode.gd



func _ready():
	$Animations.play("idle")
	currGridSize = $rightGridLocation.position.x
	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key when entering battle mode
		position.x += currGridSize
	if Input.get_action_strength("ui_left") > 0:
		position.x -= currGridSize
	if Input.get_action_strength("ui_up") > 0:
		position.y -= currGridSize
	if Input.get_action_strength("ui_down") > 0:
		position.y += currGridSize
	
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
		position.x += ((1.0 * bigGridLocationsx[currentGridSquare.x]-position.x) / $Animations/moveTilesTimer.time_left) * delta
		position.y += ((1.0 * bigGridLocationsy[currentGridSquare.y]-position.y) / $Animations/moveTilesTimer.time_left) * delta
func _input(event):
	if currState == DEFENSE:
		if(event.is_action_pressed("ui_up")):
			handleInput()
			storagePos.y -= currGridSize
		elif(event.is_action_released("ui_up")):
			handleInput()
			storagePos.y += currGridSize
		elif(event.is_action_pressed("ui_down")):
			handleInput()
			storagePos.y += currGridSize
		elif(event.is_action_released("ui_down")):
			handleInput()
			storagePos.y -= currGridSize
		elif(event.is_action_pressed("ui_right")):
			handleInput()
			storagePos.x += currGridSize
		elif(event.is_action_released("ui_right")):
			handleInput()
			storagePos.x -= currGridSize
		elif(event.is_action_pressed("ui_left")):
			handleInput()
			storagePos.x -= currGridSize
		elif(event.is_action_released("ui_left")):
			handleInput()
			storagePos.x += currGridSize		
func handleInput():
	if $inputTimer.time_left == 0:
		$HurtBox/CollisionShape2D.disabled = true
		$HitBox/CollisionShape2D.disabled = true
		$ColorRect.visible = false
		$inputTimer.start()
func _on_inputTimer_timeout():
	position = storagePos
	$Animations.flip_v = false
	$Animations.play("land")
	$HurtBox/CollisionShape2D.disabled = false
	$HitBox/CollisionShape2D.disabled = false
	$ColorRect.visible = true

# GET HIT 	

func getHit(damage:int):
	currentHP -= 1 * abs(Global.currCombatTimeMultiplier)
	emit_signal("PlayerHit")
	if currentHP <= 0:
		die()
func die():
	set_process_input(false)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$Animations.play("die")

# OFFENSE MODE (called by BattleMode.gd)

func _on_BattleMode_offensePhaseEnding():
	currState = DEFENSE
func _on_BattleMode_offensePhaseStarting():
	currState = IMOBILE
func startWindWatch():
	$Animations.play("wind watch")
	currState = IMOBILE
func finishWindWatch():
	$Animations.play("idle")
func move(direction):
	if canMove(direction):
		updateCurrGridSquare()
		moveDirection = direction
#		currentGridSquare += moveVectors[moveDirection]
		$Animations/moveTilesTimer.start()
		currState = MOVINGTILES
		$Animations.play(moveAnimations[direction])
func canMove(direction):
	if direction == UP and currentGridSquare.y == 0:
		return false
	elif direction == DOWN and currentGridSquare.y == 4:
		return false
	elif direction == LEFT and currentGridSquare.x == 0:
		return false
	elif currentGridSquare.x == 4:
		return false
	else:
		return true
func updateCurrGridSquare():
	if moveDirection == UP:
		currentGridSquare.y -= 1
	elif moveDirection == DOWN:
		currentGridSquare.y += 1
	elif moveDirection == LEFT:
		currentGridSquare.x -= 1
	else:
		currentGridSquare.x += 1
func _on_moveTilesTimer_timeout():
	currState = IMOBILE
	$Animations.play("idle")
