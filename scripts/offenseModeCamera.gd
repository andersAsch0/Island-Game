extends Camera2D



var battleModePlayerNode
onready var gridCenter = get_node("../gridCenter")
onready var grid = get_node("../gridCenter/bigGrid3")
onready var globalGridPos = gridCenter.rect_position # since grid child is at 0,0
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
	position = Global.getPlayerCoords() + vec
	grid.position = globalGridPos - (battleModePlayerNode.position * gridCenter.rect_scale)
	gridCenter.rect_position = battleModePlayerNode.position
	gridCenter.startAngleChangeTo2D()

func _on_BattleModePlayer_playerMovedOffense(_direction, _newTile, _timeToMove):
	setFollow(true)
