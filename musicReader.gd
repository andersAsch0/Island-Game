extends Node2D


var currMeasure:int = 1




func _on_MusicHandler_newMeasure():
	currMeasure += 1
	$Label.text = currMeasure as String
	
func _input(event):
	if event.is_action_pressed("dash"): #space
		$MusicHandler.timeHasStopped(100)
	elif event.is_action_pressed("enter_fight"): #F
		$MusicHandler.timeHasResumed()
	elif event.is_action_pressed("stopTime"): #E?
		print(currMeasure)
