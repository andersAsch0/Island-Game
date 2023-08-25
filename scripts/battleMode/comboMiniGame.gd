extends Node2D

enum{
	RIGHT
	LEFT
	UP
	DOWN
}

#combo data: these must all be the same length!!
var enabledCombos = [true, true]
var allCombos = [[UP, UP, DOWN], [UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT]]
var comboAnims = ["combo!!!", "BIG combo!!!"]
var comboDamage = [1, 5]

var arrowNodes = []
func _ready():
	arrowNodes = [$Arrows/rightArrow, $Arrows/leftArrow, $Arrows/upArrow, $Arrows/downArrow]
	
signal successfulCombo(damage)

func playGame():
	$Arrows.visible = true
	set_process_input(true)
func endGame():
	$Arrows.visible = false
	set_process_input(false)
	
var currCombo = []
func _input(event):
	if event.is_action_pressed("ui_right"):
		processInput(RIGHT)
	elif event.is_action_pressed("ui_left"):
		processInput(LEFT)
	elif event.is_action_pressed("ui_up"):
		processInput(UP)
	elif event.is_action_pressed("ui_down"):
		processInput(DOWN)
	elif event.is_action_released("ui_right"):
		processRelease(RIGHT)
	elif event.is_action_released("ui_left"):
		processRelease(LEFT)
	elif event.is_action_released("ui_up"):
		processRelease(UP)
	elif event.is_action_released("ui_down"):
		processRelease(DOWN)
		
func processInput(directionEnum):
	currCombo.append(directionEnum)
	currComboIndex = checkCombo()
	if currComboIndex != -1:
		displayCombo(currComboIndex)
	arrowNodes[directionEnum].play("pressed")
	$Timer.start()
func processRelease(directionEnum):
	arrowNodes[directionEnum].play("default")

func checkCombo(): #just check if the current one is valid, if so return index in the combo list, else return -1
	return allCombos.find(currCombo)
func displayCombo(comboIndex): #do anim for current combo
	$comboAnims.play(comboAnims[comboIndex])
func enactCombo(comboIndex): #carry out current combo
	emit_signal("successfulCombo", comboDamage[comboIndex])
	print("did combo ", comboIndex, " for ", comboDamage[comboIndex], " damage")
	
var currComboIndex
func _on_Timer_timeout():
	currComboIndex = checkCombo()
	if currComboIndex == -1:
		$comboAnims.play("failedCombo")
	else:
		enactCombo(currComboIndex)
		
	currCombo.clear()
