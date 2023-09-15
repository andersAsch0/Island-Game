extends Node2D


func _on_overworldScene_playerEntered(_entryPoint, _despawnList):
	$YSort/Door.playClosingAnim()

