extends Camera2D



var battleModePlayerNode
onready var grid = get_node("../bigGridController")
onready var globalGridPos = grid.position # since grid child is at 0,0
var shouldFollow = true
var vec = Vector2(0, -20)
var shaking: bool = false
var shakeDuration: float = 0.0 #also counts down to 0
var pulseDuration: float = 0.0 # ''

func _ready():
	battleModePlayerNode = get_node("../BattleModePlayer")
	set_physics_process(false)
	
func _process(delta):
	if shaking:
		offset_h = rand_range(-1.0, 1.0) * 0.02
		offset_v = rand_range(-1.0, 1.0) * 0.02
		shakeDuration -= delta
		if shakeDuration <=0:
			shaking = false
			offset = Vector2.ZERO
	if shouldFollow:
		position = battleModePlayerNode.position + vec
		
func _physics_process(delta):
	pulseDuration -= delta
	if pulseDuration <= 0:
		zoom = Vector2(1,1)
		set_physics_process(false)
		return
	zoom.x -= (zoom.x - 1) / pulseDuration * delta
	zoom.y -= (zoom.y - 1) / pulseDuration * delta

func setFollow(enable : bool):
	shouldFollow = enable
func snapToPlayer():
	position = Global.getPlayerCoords() + vec
#	grid.position = globalGridPos - (battleModePlayerNode.position * gridCenter.rect_scale)
#	gridCenter.rect_position = battleModePlayerNode.position
#	grid.startAngleChangeTo2D()

func _on_BattleModePlayer_playerMovedOffense(_direction, _newTile, _timeToMove):
	setFollow(true)

func cameraShake(time : float):
	shakeDuration = time
	shaking = true
	
func cameraPulse(time : float = 0.3, magnitude : float = 0.01):
	pulseDuration = time
	zoom += Vector2(magnitude, magnitude)
	set_physics_process(true)
