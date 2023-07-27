extends KinematicBody2D

export var battleModeVersionScenePath : String = "res://scenes/BattleModeBee.tscn"
# also, you must change the kinematicbody2d node's name to something unique so the game knows which enemy to despawn
func _ready():
	$AnimatedSprite.play("idle")
	
func die():
#	queue_free()
	visible = false
	#dont free, instead leave corpse???
func get_battleModeVersionScenePath():
	return battleModeVersionScenePath
