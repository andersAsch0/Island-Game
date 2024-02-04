extends Node2D

var active = false #button is pressed and extended to show minigame ui
var enabled = false
@export var activePos = Vector2(-60, 0)
var hiddenPos = Vector2(32, 0)
var enabledPos = Vector2.ZERO

func _ready():
	$blankButton.position = hiddenPos

var targetPos = Vector2()
var movementTimeSec = 0.2
func _process(delta):
	$blankButton.position += delta * (targetPos - $blankButton.position) / movementTimeSec
	if abs($blankButton.position.x - targetPos.x) < 1:
		set_process(false)
	

func showButton(enable: bool):
	enabled = enable
	if enable and active:
		targetPos = activePos
		set_process(true)
	elif enable:
		targetPos = enabledPos
		set_process(true)
	else:
		targetPos = hiddenPos
		active = false
		set_process(true)
	

func activate(enable: bool):
	if enabled:
		if enable:
			targetPos = activePos
		else:
			targetPos = enabledPos
		active = enable
		set_process(true)

