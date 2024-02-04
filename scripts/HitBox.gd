class_name HitBox

extends Area2D

@export var damage = 1

#func _init():
#	collision_layer = 16 #default = layer 5: I am a enemy hitbox
#	collision_mask = 0

func setCollisionLayer(layer:int):
	collision_layer = layer

