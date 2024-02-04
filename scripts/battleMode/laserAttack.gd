extends Node2D

#laserContainer's location is where the laser is spawning at / emerging from, with the laser going downwards

@export var warning : PackedScene
@export var bullet : PackedScene

func attack(timeInAdvance : float):
	var laserWarningNode = warning.instantiate()
	laserWarningNode.lengthOfWarningSeconds = timeInAdvance
	laserWarningNode.bulletPackedScene = bullet
	add_child(laserWarningNode)
