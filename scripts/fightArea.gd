class_name overworldEnemyFightTriggerArea
extends Area2D

var BattleModePath = "res://scenes/battleMode/BattleMode.tscn"
###if you want the player to spawn somewhere else when they return from the fight
#@export var overworldSceneReturnOverride : String
# this same script is used for ALL fight areas of enemies
func _input(event):
	if len(get_overlapping_bodies()) != 0 and event.is_action_pressed("enter_fight"):
		enterFight()
		

func enterFight():
	if findOverworldNode() is overworldScene && get_parent() is overworldEnemyBase:
		Global.enterBattleMode(findOverworldNode().fileSystemPath, get_parent().position, get_parent().get_path(), get_parent().battleModeVersionScenePath)
	else: 
		print("Error: can't find valid overworldEnemy parent and/or overworldScene")

##goes up the tree of nodes until it finds the biggest owner. 
##This assumes that the enemy will always be in an overworld scene with an OverworldScene node at the top
func findOverworldNode() -> overworldScene:
	var n : Node = self
	while n.owner != null:
		n = n.owner
	return n
	
