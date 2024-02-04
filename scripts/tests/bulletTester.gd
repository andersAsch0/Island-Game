extends Node2D

@export var bulletSpawner : PackedScene
@export var bulletScene : PackedScene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("ui_accept"):
		spawnBullet()

var bullet
func spawnBullet():
	bullet = bulletSpawner.instantiate().init(bulletScene, 5, 0.1, 1, false)
	add_child(bullet)
