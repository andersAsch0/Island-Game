extends AnimatedSprite

func _ready():
	play()

var moveVectors : PoolVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]

func updateSelf(myDirection):
	if get_node("/root/BattleMode").canMoveTo(get_node("/root/BattleMode/BattleModePlayer").currentGridSquare + moveVectors[myDirection]):
		visible = true
		$moveButton.set_deferred("disabled", false)
	else:
		visible = false
		$moveButton.set_deferred("disabled", true)
