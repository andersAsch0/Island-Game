extends KinematicBody2D


const acc  = 25
const max_speed = 50
const friction = 400

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized() * max_speed
	velocity = input * delta

	
	if input.length() > 0:
		$AnimatedSprite.flip_h = input.x < 0
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")
		# add run button? makes you go faster but raises suspicion or exhausts you?
	
	move_and_collide(velocity)


#func _process(delta):
#	pass
