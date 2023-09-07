extends KinematicBody2D
 
var battleModeVersionScenePath : String = "res://scenes/battleMode/BattleModeEnemy.tscn"
var musicAttackControllerPath : String = "res://scenes/battleMode/musicAttackController.tscn"
# also, you must change the kinematicbody2d node's name to something unique so the game knows which enemy to despawn
func _ready():
	$AnimatedSprite.play("idle")
	
func die():
	queue_free()
	#dont free, instead leave corpse???
func get_battleModeVersionScenePath():
	return battleModeVersionScenePath
func get_controller_path():
	return musicAttackControllerPath
