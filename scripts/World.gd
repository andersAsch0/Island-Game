extends Node2D


# Called when the node enters the scene tree for the first time.

#
func _on_overworldScene_playerEntered(entryPoint, despawnList, entryCoords):
	if entryPoint == 1:
		$Door.playerEnteredSceneThrough()

