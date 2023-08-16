extends PathFollow2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bulletScene : PackedScene
var bullet = null

func _ready():
	bulletScene = owner.bulletScene
# Called when the node enters the scene tree for the first time.
func spawnBullet(unitOffsetPerc, angle):
	#spawn bullet, place in proper position w proper speed 
	bullet = bulletScene.instance() 
	unit_offset = 1.0 * unitOffsetPerc / 100
	bullet.position = position
	bullet.angle = angle
	add_child(bullet)
