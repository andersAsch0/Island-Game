extends Node2D


var firstSpawnAreaPath =  "res://scenes/locations/overWorldHaven.tscn"

func _on_PlayButton_pressed():
	Global.switchOverworldScene(0,firstSpawnAreaPath)
