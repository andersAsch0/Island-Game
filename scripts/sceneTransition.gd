class_name SceneTransition

extends Area2D

export var destinationPath = ""
export var entryPointNum = 0
signal transitionTaken

func _ready():
	connect("area_entered", self, "_on_area_entered")
	
func _on_area_entered(hitbox: HitBox): #passes in null if not hitbox
	if hitbox: #only proceed if it is a hitbox
		emit_signal("transitionTaken")
		if destinationPath != "":
			Global.switchOverworldScene(entryPointNum, destinationPath)

func setCollisionLayer(layer:int):
	collision_layer = layer
