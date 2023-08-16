extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event.is_action_pressed("reverseTime"):
		Global.set_timeMultiplier(-1)
		$MusicHandler.timeHasReversed()
		$reverseTimeTimer.start()
	elif event.is_action_pressed("stopTime") and $stopTimeTimer.time_left == 0:
		Global.set_timeFlow(false)
		$MusicHandler.timeHasStopped()
		$stopTimeTimer.start()
		$reverseTimeTimer.paused = true
		$speedTimeTimer.paused = true
	elif event.is_action_pressed("speedUpTime"):
		Global.set_timeMultiplier(2)
		$MusicHandler.syncPitchWithGlobal() #
		$speedTimeTimer.start() 

func _on_reverseTimeTimer_timeout():
	Global.set_timeMultiplier(-1)
	$MusicHandler.timeHasReversedBack() 

func _on_stopTimeTimer_timeout():
	Global.set_timeFlow(true)
	$MusicHandler.timeHasResumed()
	$reverseTimeTimer.paused = false
	$speedTimeTimer.paused = false

func _on_speedTimeTimer_timeout():
	Global.set_timeMultiplier(1.0 * 1/2)
	$MusicHandler.syncPitchWithGlobal()
