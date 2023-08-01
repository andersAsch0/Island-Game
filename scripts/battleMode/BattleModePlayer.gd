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
		position.x += moveVectors[moveDirection].x * delta
		position.y += moveVectors[moveDirection].y * delta
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
	currState = MOVINGTILES
	moveDirection = direction
	$Animations.play(moveAnimations[direction])
	$Animations/moveTilesTimer.start()
func _on_moveTilesTimer_timeout():
	currState = IMOBILE
	$Animations.play("idle")
