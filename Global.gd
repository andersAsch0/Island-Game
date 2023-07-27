#this is a global script (created via project settings > autoload)
#it is always running, and thus this variable is always accessible to other scripts
#STORES GLOBALLY NEEDED VARIABLES

extends Node

var door_name = null
signal timeMultiplierChanged
signal timeFlowChanged

var overWorldLocation = Vector2(62, 43) #stored location for use when loading back into overworld from fight
var overWorldDeadEnemiesList = [] #list of SCENETREE PATHS
var battleModeEnemyPath : String = "" #path to battlemode version for fighting (referring to fileSystem, not scenetree)
var overWorldEnemyPath : String = "" #path to overworld version to despawn after defeating ^ (referring to scenetree)
var mostRecentOverWorldEnemyName : String = ""
var overWorldShouldDespawnEnemy = false #when loading into the overworld, this is used to know if it should despawn an enemy

var currCombatTimeMultiplier : float = 1 #should NEVER be zero OK???
var timeIsNotStopped : bool = true
#var timeIsNotStopped : int = 1 #1 when time is flowing, 0 when it is stopped (this is stupid but its gdscripts fault)

func set_timeMultiplier(n : float):
	currCombatTimeMultiplier *= n
	emit_signal("timeMultiplierChanged") #only used for sprites and stuff, NOT MOVEMENT

func set_timeFlow(timeIsNotStoppedBool: bool):
	timeIsNotStopped = timeIsNotStoppedBool
	emit_signal("timeFlowChanged")

func updateDeadEnemyList(list : Array):
	list.append(overWorldEnemyPath)
