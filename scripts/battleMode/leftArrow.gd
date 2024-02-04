extends AnimatedSprite2D

var currXGridLocation = 2

func _ready():
	play()

func updateSelf(goingMyDirection : bool):
	if goingMyDirection:
		currXGridLocation -= 1
	else:
		currXGridLocation += 1
	if currXGridLocation <= 0:
		visible = false
		$leftMoveButton.set_deferred("disabled", true)
	else:
		visible = true
		$leftMoveButton.set_deferred("disabled", false)
