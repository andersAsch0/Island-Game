class_name overworldEnemyBase
extends AnimatableBody2D

@export var battleModeVersionScenePath : String

func _ready():
	y_sort_enabled = true
func die():
	queue_free()

