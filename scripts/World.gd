extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# this script only runs on World scene when it is loaded
	$YSort/Player.position = Global.overWorldLocation	
	for deadEnemyPath in Global.overWorldDeadEnemiesList:
		get_node(deadEnemyPath).die()
		
			

