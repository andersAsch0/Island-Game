extends AnimatedSprite

var currYGridLocation = 2

func _ready():
	play()

func updateSelf(goingMyDirection : bool):
	if goingMyDirection:
		currYGridLocation += 1
	else:
		currYGridLocation -= 1
	if currYGridLocation >= 4:
		visible = false
		$downMoveButton.set_deferred("disabled", true)
	else:
		visible = true
		$downMoveButton.set_deferred("disabled", false)
