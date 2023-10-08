extends Node2D

var active = false #button is pressed and extended to show minigame ui
export var activePos = Vector2(-70, 0)
var hiddenPos = Vector2(32, 0)
var enabledPos = Vector2.ZERO


#will replace w sliding animations probably

func showButton(enable: bool):
	activate(false)
	visible = enable
	if enable and active:
		$blankButton.position = activePos
	elif enable:
		$blankButton.position = enabledPos
	else:
		$blankButton.position = hiddenPos
	

func activate(enable: bool):
	if visible:
		$blankButton.position = activePos * Vector2((enable as int), 0)
		active = enable

