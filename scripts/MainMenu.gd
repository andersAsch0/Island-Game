extends Node2D


var firstSpawnAreaPath = "res://scenes/World.tscn"

func _on_PlayButton_pressed():
	var _PTS = get_tree().change_scene(firstSpawnAreaPath) # change_scene takes path, change_scene_to takes PackedScene
