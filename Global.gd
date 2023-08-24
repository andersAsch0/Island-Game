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

#ENEMY DE/SPAWNING FOR BATTLEMODE
var overWorldLocation = Vector2(62, 43) #stored location for use when loading back into overworld from fight
var overWorldDeadEnemiesList = [] #list of SCENETREE PATHS
var battleModeEnemyPath : String = "" #path to battlemode version for fighting (referring to fileSystem, not scenetree)
var overWorldEnemyPath : String = "" #path to overworld version to despawn after defeating ^ (referring to scenetree)
var mostRecentOverWorldEnemyName : String = ""
var overWorldShouldDespawnEnemy = false #when loading into the overworld, this is used to know if it should despawn an enemy
func updateDeadEnemyList(list : Array): #all enemies are alive by default, as you defeat them they are added onto the dead list
	list.append(overWorldEnemyPath) #this is called after a battle, to add the defeated enemy onto that scene's dead list
	

#BATTLEMODE GRID TRACKING (so all nodes can know where the enemy & player are)
var gridCoordsY = [-30, 33, 110, 205, 330]
var gridCoordsX = [[-9, 76, 160, 248, 335], [-31, 66, 162, 256, 355], [-48, 57, 162, 268, 374], [-80, 41, 159, 280, 407], [-115, 21, 161, 295, 436]]
var bigGridLocationsx = [18, 90, 160, 230, 300 ]
var bigGridLocationsy = [-30, 40, 110, 180, 250]

var playerGridLocation = Vector2(2,2)
var enemyGridLocation = Vector2(2,1)
func setPlayerGridLocation( newLocation : Vector2):
	playerGridLocation = newLocation
func setEnemyGridLocation( newLocation : Vector2):
	enemyGridLocation = newLocation

func getEnemyCoords():
	return Vector2(gridCoordsX[enemyGridLocation.y][enemyGridLocation.x], gridCoordsY[enemyGridLocation.y])
func getPlayerCoords():
	return Vector2(gridCoordsX[playerGridLocation.y][playerGridLocation.x], gridCoordsY[playerGridLocation.y])
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
