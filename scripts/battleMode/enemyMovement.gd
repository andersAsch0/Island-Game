extends Path2D

export var enemySpeed : int
#used for all enemeyMovements
var lastTickOffset : float
func _ready():
	set_process(false)
	set_physics_process(false)

#silly
func _process(delta):
	$PathFollow2D.set_offset($PathFollow2D.get_offset() + enemySpeed * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int))
func _physics_process(delta):
	($PathFollow2D.offset += enemySpeed * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int))
	if $PathFollow2D.offset < lastTickOffset:
		$PathFollow2D.offset = 0
		set_physics_process(false)
	lastTickOffset = $PathFollow2D.offset

func wander():
	set_process(true)
func returnToMiddle():
	set_process(false)
	lastTickOffset = $PathFollow2D.unit_offset
	set_physics_process(true)
