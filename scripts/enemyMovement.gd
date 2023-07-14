extends Path2D

export var enemySpeed : int

func _process(delta):
	$PathFollow2D.set_offset($PathFollow2D.get_offset() + enemySpeed * delta)
