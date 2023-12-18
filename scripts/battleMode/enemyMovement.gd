extends Path2D

export var enemySpeed : int
#used for all enemeyMovements
var lastTickOffset : float
func _ready():
	set_process(false)
	set_physics_process(false)

#silly
func _process(delta):
	$PathFollow2D.set_offset($PathFollow2D.get_offset() + wanderSpeed * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int))

var wanderSpeed
func wander(duration : float):
	wanderSpeed = calculateWanderSpeed(duration)
	set_process(true)
func stopWander(_duration):
	set_process(false)
	$PathFollow2D.offset = 0

func calculateWanderSpeed(duration : float)-> float:
#find value closest to enemySpeed that also gives a whole number of rotations
#actual speed = path length * # of rotations / duration
	if duration == 0: return 0.0
	var tempWanderSpeed = curve.get_baked_length() / duration # one rotation
	var numRotations = 2
	while true:
		#if speed with more roations is closer to enemyspeed, continue
		# if speed w one more rotation is further, use the previous one
		var distFromEnemySpeed = abs(tempWanderSpeed - enemySpeed)
		if abs((curve.get_baked_length() / duration * numRotations )-enemySpeed) >= distFromEnemySpeed:
			return (tempWanderSpeed)
		tempWanderSpeed = (curve.get_baked_length() / duration * numRotations )
		numRotations += 1
	
	return 0.0

