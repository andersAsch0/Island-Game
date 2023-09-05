extends Path2D

export var enemySpeed : int
#used for all enemeyMovements

func _process(delta):
	$PathFollow2D.set_offset($PathFollow2D.get_offset() + enemySpeed * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int))
