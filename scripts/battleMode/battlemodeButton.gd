extends Node2D

var enabled = false #button can be pressed
var active = false #button is pressed and extended to show minigame ui
var activePos = Vector2(-70, 0)
var hiddenPos = Vector2(32, 0)
var enabledPos = Vector2.ZERO

func showButton(enable: bool):
	visible = enable
	enabled = enable
	$blankButton.position = Vector2.ZERO

func activate(enable: bool):
	if enabled:
		$blankButton.position = Vector2((enable as int) * -70, 0)
		active = enable
