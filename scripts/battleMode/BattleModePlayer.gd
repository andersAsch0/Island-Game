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


func _process(delta):
	
	#movement
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized() * max_speed

	velocity = input * delta

	
	if input.length() > 0:
		if (input.y) > 0: #going down
			direction = DOWN
		elif input.y < 0: #going up
			direction = UP
		elif input.x > 0: #going right
			direction = RIGHT
		elif input.x < 0:
			direction = LEFT
	
	if(input.length()==0):
		$Animations.play("idle")
	elif(isDashing):
		velocity *= dashMultiplier
		$Animations.play(dash_animations[direction])
	else:
		$Animations.play(walk_animations[direction])
	
	move_and_collide(velocity)


func _on_DashTimer_timeout():
	isDashing = false

func _input(event):
	if(event.is_action_pressed("dash")):
		isDashing = true
		$DashTimer.start()
#	elif(event.is_action_pressed("reverseTime")):
#		reverseTime()
#	elif(event.is_action_pressed("stopTime")):
#		stopTime()
#	elif(event.is_action_pressed("speedUpTime")):
#		speedUpTime()


#func reverseTime():
#	get_tree().call_group("bulletTypes", "reverseTime") # reverse direction of ALREADY EXISTING bullets
#	get_tree().call_group("enemies", "reverseTime") # reverse direction of all future bullets spawned
#func stopTime():
#	get_tree().call_group("bulletTypes", "stopTime") # reverse direction of ALREADY EXISTING bullets
#	get_tree().call_group("enemies", "stopTime") # reverse direction of all future bullets spawned
#func speedUpTime():
#	get_tree().call_group("bulletTypes", "speedUpTime", 2) # reverse direction of ALREADY EXISTING bullets
#	get_tree().call_group("enemies", "speedUpTime", 2) # reverse direction of all future bullets spawned
func getHit(damage:int):
	print("ouch")
