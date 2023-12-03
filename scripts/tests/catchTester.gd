extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$battlemodeButton.showButton(true)


func _input(event):
	if event.is_action_pressed("heal"):
		$catchMiniGame.playGame()
	if event.is_action_pressed("windWatch"):
		$windWatchMiniGame.playGame()
		$battlemodeButton.activate($windWatchMiniGame.is_processing_input())
	elif event.is_action_pressed("attack"):
		$comboMiniGame.playGame()
