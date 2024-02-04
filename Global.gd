#this is a global script (created via project settings > autoload)
#it is always running, and thus this variable is always accessible to other scripts
#STORES GLOBALLY NEEDED VARIABLES

extends Node


signal timeFlowHasChanged(newTimeFlow, duration, start) #newtimeflow will be 0 if time has stopped
signal timeHasChangedSpeed(duration, start, distortionTypeIsSpeed) #not emitted when time starts / stops, newTimeFlow will never be 0
signal timeHasStoppedOrStarted(duration, start) #start is a bool to indicate its the beginning of the distortion
signal timeHasReversed(duration, start)

#TIME CONTROL FOR BATTLEMODE
var currCombatTimeMultiplier : float = 1 #should NEVER be zero OK???
var timeIsNotStopped : bool = true
func changeTimeSpeed(multiplier : float, _distortionTypeIsSpeed : bool, duration : float, start : bool):
	currCombatTimeMultiplier *= multiplier
	emit_signal("timeFlowHasChanged", currCombatTimeMultiplier * (timeIsNotStopped as int), duration, start)
	emit_signal("timeHasChangedSpeed", duration, start, true)
func startOrStopTime(newFlow : bool, duration : float, start : bool): #false is stopped, true is flowing
	if newFlow != timeIsNotStopped:
		timeIsNotStopped = newFlow
		emit_signal("timeFlowHasChanged", currCombatTimeMultiplier * (timeIsNotStopped as int), duration, start)
		emit_signal("timeHasStoppedOrStarted", duration, start)
func reverseTime(newTimeDirection : bool, duration, start): #true is reversed, false is normal
	if newTimeDirection!= (currCombatTimeMultiplier <= 0):
		currCombatTimeMultiplier *= -1
		emit_signal("timeFlowHasChanged", currCombatTimeMultiplier * (timeIsNotStopped as int), duration, start)
		emit_signal("timeHasReversed", duration, start)



#BATTLEMODE ENTERING AND EXITING
#I know these names are awful I KNOW
var battleModePath = "res://scenes/battleMode/BattleMode.tscn" # path of (empty) battlemode in filesystem
var spawnPlayerAtPrevOverworldCoords = false #this will be true when returning to overworld from battlemode, and so the overworldScene will spawn the player accordingly
func enterBattleMode(overWorldFileSystemPath : String, respawnPos : Vector2, OenemyPath : String, BMenemyPath : String, controllerPath : String):
	overWorldPath = overWorldFileSystemPath # path of the scene of the whole overworld in the filesystem
	overWorldEnemyPath = OenemyPath # path of the overworld enemy in the filesystem
	battleModeEnemyPath = BMenemyPath # path of the battlemode version in the filsystem
	musicAttackControllerPath = controllerPath # ditto
	leaveOverworld(respawnPos, battleModePath)
func leaveOverworld(respawnPos : Vector2, newScene : String):
	overWorldLocation = respawnPos # location where player will respawn in when they leave battlemode and go back to the overworld
	var _PTS = get_tree().change_scene_to_file(newScene) # change_scene_to_file takes path, change_scene_to_packed takes PackedScene
var overWorldPath = "res://scenes/overworldPrototype.tscn"
func reEnterOverworld():
	var _PTS = get_tree().change_scene_to_file(overWorldPath) # change_scene_to_file takes path, change_scene_to_packed takes PackedScene
	spawnPlayerAtPrevOverworldCoords = true
func getPrevOverworldPlayerCoords():
	spawnPlayerAtPrevOverworldCoords = false
	return overWorldLocation
	


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
	if gridCoords == []: 
		print("warning: grid coords not set")
		return Vector2.ZERO
	return gridCoords[enemyGridLocation.y][enemyGridLocation.x]
func getPlayerCoords():
	if gridCoords == []: 
		print("warning: grid coords not set")
		return Vector2.ZERO
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
	get_tree().change_scene_to_file(destinationPath) # change_scene_to_file takes path, change_scene_to_packed takes PackedScene
	

#ENTITY DESPAWNING MASTER LIST (each location has its own index correspondind to an entry in this array
var despawnList = [
	[],
	[],
	[]
]
