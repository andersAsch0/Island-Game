extends Path2D


var bulletScene : PackedScene
var bullet = null

func _ready():
	bulletScene = owner.bulletScene
# Called when the node enters the scene tree for the first time.
func spawnBullet(offsetPerc, angle):
	#spawn bullet, place in proper position w proper speed 
	bullet = bulletScene.instance() 
	$bulletSpawnLocation.unit_offset = 1.0 * offsetPerc / 100
	bullet.position = $bulletSpawnLocation.position
	bullet.angle = angle
	add_child(bullet)

func rotateBulletSpawnPath():
	var enemyDisplacement = Global.getEnemyDisplacementFromPlayer()
	if enemyDisplacement.y == 0: # on same y row
		rotation_degrees = 90 * enemyDisplacement.x
		global_position.y = Global.getPlayerCoords().y
	else: # on same x column
		rotation_degrees = 180 * ((enemyDisplacement.y > 1) as int)
		global_position.x = Global.getPlayerCoords().x
