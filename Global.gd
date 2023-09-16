#this is a global script (created via project settings > autoload)
#it is always running, and thus this variable is always accessible to other scripts
#STORES GLOBALLY NEEDED VARIABLES

extends Node

var door_name = null
signal timeMultiplierChanged
signal timeFlowChanged

#TIME CONTROL FOR BATTLEMODE
var currCombatTimeMultiplier : float = 1 #should NEVER be zero OK???
var timeIsNotStopped : bool = true
func set_timeMultiplier(n : float):
	currCombatTimeMultiplier *= n
	emit_signal("timeMultiplierChanged") #only used for sprites and stuff, NOT MOVEMENT
func set_timeFlow(timeIsNotStoppedBool: bool):
	timeIsNotStopped = timeIsNotStoppedBool
	emit_signal("timeFlowChanged")

#BATTLEMODE ENTERING AND EXITING
var battleModePath = "res://scenes/battleMode/BattleMode.tscn"
func enterBattleMode(respawnPos : Vector2, OenemyPath : String, BMenemyPath : String, controllerPath : String):
	overWorldEnemyPath = OenemyPath
	battleModeEnemyPath = BMenemyPath
	musicAttackControllerPath = controllerPath
	leaveOverworld(respawnPos, battleModePath)
func leaveOverworld(respawnPos : Vector2, newScene : String):
	overWorldLocation = respawnPos
	var _PTS = get_tree().change_scene(newScene) # change_scene takes path, change_scene_to takes PackedScene
var overWorldPath = "res://scenes/World.tscn"
func reEnterOverworld():
	var _PTS = get_tree().change_scene(overWorldPath) # change_scene takes path, change_scene_to takes PackedScene


#BATTLEMODE GRID TRACKING (so all nodes can know where the enemy & player are)
var gridCoords = []
#var bigGridLocationsx = [18, 90, 160, 230, 300 ]
#var bigGridLocationsy = [-30, 40, 110, 180, 250]

var playerGridLocation = Vector2(2,2)
var enemyGridLocation = Vector2(2,1)
func setPlayerGridLocation( newLocation : Vector2):
	playerGridLocation = newLocation
func setEnemyGridLocation( newLocation : Vector2):
	enemyGridLocation = newLocation

func getEnemyCoords():
	return gridCoords[enemyGridLocation.y][enemyGridLocation.x]
func getPlayerCoords():
	return gridCoords[playerGridLocation.y][playerGridLocation.x]
func getEnemyDisplacementFromPlayer():
	return enemyGridLocation - playerGridLocation

func canMoveTo(gridLocation : Vector2):
	if gridLocation.x > 4 or gridLocation.x < 0:
		return false
	if gridLocation.y > 4 or gridLocation.y < 0:
		return false
	elif gridLocation == enemyGridLocation:
		return false
	else:
		return true

#ENEMY DE/SPAWNING FOR BATTLEMODE
var currDespawnListIndex : int = 0
var overWorldLocation = Vector2(62, 43) #stored location for use when loading back into overworld from fight
var overWorldDeadEnemiesList = [] #list of SCENETREE PATHS
var battleModeEnemyPath : String = "" #path to battlemode version for fighting (referring to fileSystem, not scenetree)
var musicAttackControllerPath : String = ""
var overWorldEnemyPath : String = "" #path to overworld version to despawn after defeating ^ (referring to scenetree)
func battleModeEnemyDefeated(): #all enemies are alive by default, as you defeat them they are added onto the dead list
	appendDespawnList(currDespawnListIndex, overWorldEnemyPath)
func appendDespawnList(despawnListIndex : int, entityPath : String):
	despawnList[despawnListIndex].append(entityPath)
func eraseFromDespawnList(despawnListIndex : int, entityPath : String):
	despawnList[despawnListIndex].erase(entityPath)

#OVERWORLD MOVEMENT THROUGH DIFFERENT SCENES
var latestEntryNum : int = 0
func switchOverworldScene(entryPoint : int, destinationPath : String):
	latestEntryNum = entryPoint
	var _PTS = get_tree().change_scene(destinationPath) # change_scene takes path, change_scene_to takes PackedScene
	
	
	
	

#ENTITY DESPAWNING MASTER LIST (each location has its own index correspondind to an entry in this array
var despawnList = [
	[],
	[],
	[]
]
