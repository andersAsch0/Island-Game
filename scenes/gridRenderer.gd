extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	$startTimer.start()

func _process(delta):
	$Sprite3D.rotation_degrees.x += delta * 30
	if $Sprite3D.rotation_degrees.x >= 145:
		set_process(false)
#	$Path/PathFollow.offset += delta / 2.0
#	$Path/PathFollow/Camera.rotation_degrees.x -= 60.0 * delta / 2.0
#	if $Path/PathFollow/Camera.rotation_degrees.x <= -90:
#		set_process(false)
	


func _on_startTimer_timeout():
	set_process(true)
