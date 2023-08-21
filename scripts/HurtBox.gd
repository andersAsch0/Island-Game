class_name HurtBox

extends Area2D

#func _init():
#	collision_layer = 0 
#	collision_mask = 16 #default layer 6 = I detect enemy hitboxes
#
signal hurtBoxHit(damage)

func _ready():
	connect("area_entered", self, "_on_area_entered")
	
func _on_area_entered(hitbox: HitBox): #passes in null if not hitbox
	if hitbox: #only proceed if it is a hitbox
		emit_signal("hurtBoxHit", hitbox.damage)
		if owner.has_method("getHit"):
			owner.getHit(hitbox.damage)

func setCollisionLayer(layer:int):
	collision_layer = layer
