extends AnimatedSprite2D

func _ready():
	play()

var moveVectors : PackedVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]


func updateSelf(myDirection):
	if Global.canMoveTo(Global.playerGridLocation + moveVectors[myDirection]):
		visible = true
	else:
		visible = false
