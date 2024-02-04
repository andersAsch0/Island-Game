extends CharacterBody2D

@export var battleModeVersionScenePath : String = "res://scenes/battleMode/BattleModeBeeEnemy.tscn"
# also, you must change the kinematicbody2d node's name to something unique so the game knows which enemy to despawn
func _ready():
	$AnimatedSprite2D.play("idle")
	
func die():
	queue_free()
	#dont free, instead leave corpse???
func get_battleModeVersionScenePath():
	return battleModeVersionScenePath
