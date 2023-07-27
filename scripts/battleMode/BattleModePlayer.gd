extends KinematicBody2D


#const acc  = 25
#const max_speed = 50
#const friction = 400
#var dashMultiplier = 5
#var isDashing = false
#enum {
#	LEFT, 
#	RIGHT,
#	UP,
#	DOWN
#}
#var walk_animations = ["horizontal", "horizontal", "vertical", "vertical"]
#var dash_animations = ["dash left", "dash right", "dash up", "dash down"]
#var direction = UP
var gridSize = 20
var velocity = Vector2.ZERO
var storagePos = Vector2.ZERO #used as storage during input calculations for jumping
export var maxHP : int = 4
export var currentHP : int = maxHP
export var invincible : bool = true #for debugging #only works if you dont move

signal PlayerHit

func _ready():
	$Animations.play("idle")
	gridSize = $rightGridLocation.position.x
	if Input.get_action_strength("ui_right") > 0: # fixes things if the player is holding down a key when entering battle mode
		position.x += gridSize
	if Input.get_action_strength("ui_left") > 0:
		position.x -= gridSize
	if Input.get_action_strength("ui_up") > 0:
		position.y -= gridSize
	if Input.get_action_strength("ui_down") > 0:
		position.y += gridSize
	storagePos = position
	if invincible:
		$HurtBox/CollisionShape2D.set_deferred("disabled", true)
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
	
func _process(delta):
	if $inputTimer.time_left > 0: #if mid jump
		position.x += (storagePos.x - position.x)/$inputTimer.time_left * delta
		position.y += (storagePos.y - position.y)/$inputTimer.time_left * delta
		if abs(storagePos.x - position.x) >= abs(storagePos.y - position.y):
			$Animations.animation = "ball horizontal"
			$Animations.flip_h = storagePos.x < position.x
		else:
			$Animations.animation = "ball vertical"
			$Animations.flip_v = storagePos.y < position.y
	
#	#movement
#	var input = Vector2.ZERO
#	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
#	input = input.normalized() * max_speed
#
#	velocity = input * delta
#
#
#	if input.length() > 0:
#		if (input.y) > 0: #going down
#			direction = DOWN
#		elif input.y < 0: #going up
#			direction = UP
#		elif input.x > 0: #going right
#			direction = RIGHT
#		elif input.x < 0:
#			direction = LEFT
#
#	if(input.length()==0):
#		$Animations.play("idle")
#	elif(isDashing):
#		velocity *= dashMultiplier
#		$Animations.play(dash_animations[direction])
#	else:
#		$Animations.play(walk_animations[direction])
#
#	move_and_collide(velocity)
	pass

#func _on_DashTimer_timeout():
#	isDashing = false

func _input(event):
#	if(event.is_action_pressed("dash")):
#		isDashing = true
#		$DashTimer.start()
	if(event.is_action_pressed("ui_up")):
		handleInput()
		storagePos.y -= gridSize
	elif(event.is_action_released("ui_up")):
		handleInput()
		storagePos.y += gridSize
	elif(event.is_action_pressed("ui_down")):
		handleInput()
		storagePos.y += gridSize
	elif(event.is_action_released("ui_down")):
		handleInput()
		storagePos.y -= gridSize
	elif(event.is_action_pressed("ui_right")):
		handleInput()
		storagePos.x += gridSize
	elif(event.is_action_released("ui_right")):
		handleInput()
		storagePos.x -= gridSize
	elif(event.is_action_pressed("ui_left")):
		handleInput()
		storagePos.x -= gridSize
	elif(event.is_action_released("ui_left")):
		handleInput()
		storagePos.x += gridSize		
		
# new plan: when button is pressed, start moving immediately
# but the jump to another square takes a little time (animation w invuln)
# so during that animation, it will note any more inputs and redirect you mid jump
# (bur doesnt restart jump time, so jumps are always the same length to avoid most cheesing)

		
func handleInput():
	if $inputTimer.time_left == 0:
		$HurtBox/CollisionShape2D.disabled = true
		$HitBox/CollisionShape2D.disabled = true
		$ColorRect.visible = false
		$inputTimer.start()
	# on any of those 8 actions, start timer
	# on timer end, update position
	# actions during timer cant restart it
func _on_inputTimer_timeout():
	position = storagePos
	$Animations.flip_v = false
	$Animations.play("land")
	$HurtBox/CollisionShape2D.disabled = false
	$HitBox/CollisionShape2D.disabled = false
	$ColorRect.visible = true
	
func getHit(damage:int):
	currentHP -= 1
	emit_signal("PlayerHit")
	if currentHP <= 0:
		die()
func die():
	set_process_input(false)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$Animations.play("die")
