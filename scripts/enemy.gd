extends KinematicBody2D


func _ready():
	$AnimatedSprite.play("idle")
	
func die():
	queue_free()
	#dont free, instead leave corpse???
