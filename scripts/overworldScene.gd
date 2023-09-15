class_name overworldScene

extends Node


export var despawnList = []

signal playerEntered(entryPoint, despawnList)

func _ready():
	emit_signal("playerEntered", Global.latestEntryNum, despawnList)

func addToDepsawnList(entityPath : String):
	despawnList.append(entityPath)

func removeFromDespawnList(entityPath: String):
	despawnList.erase(entityPath)
