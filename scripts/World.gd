extends Node2D


# Called when the node enters the scene tree for the first time.

var entryPointCoords = [Vector2(0,50), Vector2(50, 0), Vector2(100,100)]

#func _ready():
#	# this script only runs on World scene when it is loaded
#	$YSort/Player.position = Global.overWorldLocation	
#	for deadEnemyPath in Global.overWorldDeadEnemiesList:
#		get_node(deadEnemyPath).die()
#
#

func _on_overworldScene_playerEntered(entryPoint, despawnList):
	$YSort/Player.position = entryPointCoords[entryPoint]
	#play any door animations or whatever
	for deadEntityPath in despawnList:
		get_node(deadEntityPath).queue_free()
