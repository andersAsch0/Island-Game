extends Area2D

signal hit

func _process(_delta):
	if len(get_overlapping_bodies()) != 0:
		emit_signal("hit")
		
