extends KinematicBody2D


const acc  = 25
const max_speed = 50
const friction = 400
enum {
	LEFT, 
	RIGHT,
	UP,
	DOWN
}
var walk_animations = ["walk left", "walk right", "walk up", "walk down"]
var idle_animations = ["idle left", "idle right", "idle up", "idle down"]
var currDirection = DOWN

var velocity = Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	$Listener2D.make_current()

func _process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized() * max_speed
	velocity = input #* delta


	
	if input.x > 0:
		currDirection = RIGHT
	elif input.x < 0:
		currDirection = LEFT
	elif input.y > 0:
		currDirection = DOWN
	elif input.y < 0:
		currDirection = UP
	
	if input.length() > 0:
		$Animations.play(walk_animations[currDirection])
	else:
		$Animations.play(idle_animations[currDirection])
	
	move_and_slide(velocity)


#func _process(delta):
#	pass


func _on_playerFootstepMaker_currentStepMaterial(tileID):
#	print(tileID)
	if tileID == 1: # this is the tileID of water
		$Animations/waterOverFeet.visible = true
	else:
		$Animations/waterOverFeet.visible = false
