extends Node2D


func _input(event):
	if event.is_action_pressed("dash"):
		$musicAttackController.defenseModeStarting()
	elif event.is_action_pressed("ui_up"):
		$musicAttackController.offenseModeStarting()
