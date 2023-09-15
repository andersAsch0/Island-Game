extends Node2D


var firstSpawnAreaPath = "res://scenes/overworldPrototype.tscn"

func _on_PlayButton_pressed():
	Global.switchOverworldScene(0,firstSpawnAreaPath)
