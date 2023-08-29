extends Camera2D



var battleModePlayerNode
onready var gridCenter = get_node("../gridCenter")
onready var grid = get_node("../gridCenter/bigGrid")
var shouldFollow = true

func _ready():
	battleModePlayerNode = get_node("../BattleModePlayer")
	
var vec = Vector2(0, -20)
func _process(_delta):
	if shouldFollow:
		position = battleModePlayerNode.position + vec

func setFollow(enable : bool):
	shouldFollow = enable
func snapToPlayer():
	position = battleModePlayerNode.position + vec
	gridCenter.rect_position = position
	grid.global_position = Vector2(174,129)
	gridCenter.startAngleChangeTo2D()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BattleModePlayer_playerMovedOffense(_direction, _newTile, _timeToMove):
	setFollow(true)
