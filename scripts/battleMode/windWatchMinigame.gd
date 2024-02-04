extends Node2D


# Declare member variables here. Examples:
# var a = 2
enum {
	HANDUP,
	HANDRIGHT,
	HANDDOWN,
	HANDLEFT
}
var arrowRotations = [0, 90, 180, 270]
var clockWindAnims = ["up", "right", "down", "left"]
var clockStaticAnims = ["starting", "staticRight", "staticDown", "staticLeft"]
var currState = HANDUP
signal wind
signal failedWind
var arrowCurrentlyMoving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	playGame()
func _process(delta):
	if arrowCurrentlyMoving:
		$arrowRotater.rotate(6 * PI * delta)
		if $arrowRotater.rotation_degrees >= arrowRotations[getPrevState()] + 90:
			arrowCurrentlyMoving = false
			$arrowRotater.rotation_degrees = arrowRotations[currState]

func playGame(): #toggle
	visible = not visible
	set_process_input(visible)

func _input(event):
	if event.is_action_pressed("ui_right"):
		if currState == HANDUP:
			windForward(HANDRIGHT)
		else:
			windBack()
	elif event.is_action_pressed("ui_down"):
		if currState == HANDRIGHT:
			windForward(HANDDOWN)
		else:
			windBack()
	elif event.is_action_pressed("ui_left"):
		if currState == HANDDOWN:
			windForward(HANDLEFT)
		else:
			windBack()
	elif event.is_action_pressed("ui_up"):
		if currState == HANDLEFT:
			windForward(HANDUP)
		else:
			windBack()
	
func windForward(newState):
	arrowCurrentlyMoving = true
	currState = newState
	$clock.play(clockWindAnims[currState])
	$windSFX.play(0.0)
	emit_signal("wind")
func windBack():
	currState = getPrevState()
	$arrowRotater.rotation_degrees = arrowRotations[currState]
	$clock.play(clockStaticAnims[currState])
	emit_signal("failedWind")
func getPrevState():
	if currState != HANDUP:
		return currState - 1
	else:
		return HANDLEFT

func gameEnd():
	visible = false
	set_process_input(false) 
#
#func updateArrows():
#	for arrow in arrows:
#		arrow.visible = false
#	arrows[currState].visible = true
	

