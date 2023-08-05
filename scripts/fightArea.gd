extends Area2D

var BattleModePath = "res://scenes/battleMode/BattleMode.tscn"

func _input(event):
	if len(get_overlapping_bodies()) != 0 and event.is_action_pressed("enter_fight"):
		enterFight()
		

func enterFight():
	Global.overWorldLocation = owner.position
	Global.overWorldEnemyPath = owner.get_path()
	Global.battleModeEnemyPath = owner.get_battleModeVersionScenePath()
	var _PTS = get_tree().change_scene(BattleModePath) # change_scene takes path, change_scene_to takes PackedScene
