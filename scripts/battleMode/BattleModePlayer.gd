extends KinematicBody2D


const acc  = 25
const max_speed = 50
const friction = 400
var dashMultiplier = 5
var isDashing = false
enum {
	LEFT, 
	RIGHT,
	UP,
	DOWN
}
var walk_animations = ["horizontal", "horizontal", "vertical", "vertical"]
var dash_animations = ["dash left", "dash right", "dash up", "dash down"]
var direction = UP
var velocity = Vector2.ZERO
var storagePos = Vector2.ZERO

func _ready():
	storagePos = position

func _process(delta):
	
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

func _on_DashTimer_timeout():
	isDashing = false

func _input(event):
#	if(event.is_action_pressed("dash")):
#		isDashing = true
#		$DashTimer.start()
	if(event.is_action_pressed("ui_up")):
		updateInputTimer()
		storagePos.y -= 20
	elif(event.is_action_released("ui_up")):
		updateInputTimer()
		storagePos.y += 20
	elif(event.is_action_pressed("ui_down")):
		updateInputTimer()
		storagePos.y += 20
	elif(event.is_action_released("ui_down")):
		updateInputTimer()
		storagePos.y -= 20
	elif(event.is_action_pressed("ui_right")):
		updateInputTimer()
		storagePos.x += 20
	elif(event.is_action_released("ui_right")):
		updateInputTimer()
		storagePos.x -= 20
	elif(event.is_action_pressed("ui_left")):
		updateInputTimer()
		storagePos.x -= 20
	elif(event.is_action_released("ui_left")):
		updateInputTimer()
		storagePos.x += 20		
		
# new plan: when button is pressed, start moving immediately
# but the jump to another square takes a little time (animation w invuln)
# so during that animation, it will note any more inputs and redirect you mid jump
# (bur doesnt restart jump time, so jumps are always the same length to avoid most cheesing)
		
func updateInputTimer():
	if $inputTimer.time_left == 0:
		$inputTimer.start()
	# on any of those 8 actions, start timer
	# on timer end, update position
	# actions during timer cant restart it
func _on_inputTimer_timeout():
	position = storagePos
		
func getHit(damage:int):
	print("ouch")


