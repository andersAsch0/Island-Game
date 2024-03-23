class_name HitBox

extends Area2D

@export var damage = 1

#should have no collision mask (isnt detecting anything) and collision layer of what it is (ex. enemies have layer Enemyhitbox)

func setCollisionLayer(layer:int):
	collision_layer = layer

