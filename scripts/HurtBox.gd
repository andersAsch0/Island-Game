class_name HurtBox

extends Area2D

#should have no collision layer (can collide with other things) and a collision mask of what it is detecting

signal hurtBoxHit(damage)

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	
func _on_area_entered(hitbox: HitBox): #passes in null if not hitbox
	if hitbox: #only proceed if it is a hitbox
		emit_signal("hurtBoxHit", hitbox.damage)
		if owner.has_method("getHit"):
			owner.getHit(hitbox.damage)

func setCollisionLayer(layer:int):
	collision_layer = layer
