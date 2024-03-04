class_name overworldScene

extends Node

# this should be the root node for any overworld scene
# it spawns the player in the proper position and spawns the proper npcs / enemies
# the player node MUST be have the path "world/Y" and if there are any special things that need to happen when the 
#player enters, they should be scripted there (can connect to playerEntered singal)

# MAKE SURE TO SET THE EXPORT VARIABLES BELOW!!

@export var despawnListIndex : int = 0
@export var fileSystemPath : String
@export var entryPointCoords = []

signal playerEntered(entryPoint, despawnListIndex, entryCoords) #entrypoint will be -1 if entering from battlemode (not a door or edge)

func _ready():
	Global.currDespawnListIndex = despawnListIndex
	if Global.spawnPlayerAtPrevOverworldCoords:
		playerEnter(Global.getPrevOverworldPlayerCoords())
		emit_signal("playerEntered", -1, despawnListIndex, Global.getPrevOverworldPlayerCoords())
	else:
		playerEnter(entryPointCoords[Global.latestEntryNum])
		emit_signal("playerEntered", Global.latestEntryNum, despawnListIndex, entryPointCoords[Global.latestEntryNum])
	for deadEntityPath in getDespawnList():
		get_node(deadEntityPath).queue_free()

func getDespawnList():
	return Global.despawnList[despawnListIndex]

func addToDespawnList(entityPath : String):
	Global.despawnList[despawnListIndex].append(entityPath)

func removeFromDespawnList(entityPath : String):
	Global.despawnList[despawnListIndex].erase(entityPath)

func playerEnter(coords : Vector2):
	find_child("Player").position = coords
	for deadEntityPath in getDespawnList():
		get_node(deadEntityPath).queue_free()
