extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var battleModePlayerNode
var shouldFollow = true

func _ready():
	battleModePlayerNode = get_node("../BattleModePlayer")
func _process(_delta):
	if shouldFollow:
		position = battleModePlayerNode.position + Vector2(0,-20)

func setFollow(enable : bool):
	shouldFollow = enable


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BattleModePlayer_playerMovedOffense(direction):
	setFollow(true)
