class_name overworldScene

extends Node


export var despawnListIndex : int = 0
export var fileSystemPath : String

signal playerEntered(entryPoint, despawnList)

func _ready():
	Global.currDespawnListIndex = despawnListIndex
	emit_signal("playerEntered", Global.latestEntryNum, despawnListIndex)

func getDespawnList():
	return Global.despawnList[despawnListIndex]

func addToDepsawnList(entityPath : String):
	Global.despawnList[despawnListIndex].append(entityPath)

func removeFromDespawnList(entityPath : String):
	Global.despawnList[despawnListIndex].erase(entityPath)
