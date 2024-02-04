extends AnimatedSprite2D

var currYGridLocation = 2

func _ready():
	play()

func updateSelf(goingMyDirection : bool):
	if goingMyDirection:
		currYGridLocation -= 1
	else:
		currYGridLocation += 1
	if currYGridLocation <= 0:
		visible = false
		$upMoveButton.set_deferred("disabled", true)
	else:
		visible = true
		$upMoveButton.set_deferred("disabled", false)
