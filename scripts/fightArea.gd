extends Area2D

var BattleModePath = "res://scenes/battleMode/BattleMode.tscn"
# this same script is used for ALL fight areas of enemies
func _input(event):
	if len(get_overlapping_bodies()) != 0 and event.is_action_pressed("enter_fight"):
		enterFight()
		

func enterFight():
	Global.enterBattleMode(owner.position, owner.get_path(), owner.get_battleModeVersionScenePath(), owner.get_controller_path())
