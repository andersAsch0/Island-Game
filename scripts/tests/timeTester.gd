extends Node2D

var timeScalingFactor = 2
var durationPlaceholder = 5

func _input(event):

		if(event.is_action_pressed("reverseTime")):
#			$reverseTimeDuration.start()
#			musicAttackController.get_node("MusicHandler").timeHasReversed($reverseTimeDuration.wait_time)		
			reverseTime()
		elif(event.is_action_pressed("stopTime")):
#			$stopTimeDuration.start()
			stopTime()
		elif(event.is_action_pressed("speedUpTime")):
#			$speedTimeDuration.start()
			changeTimeScale(timeScalingFactor, durationPlaceholder, true)
		elif(event.is_action_pressed("slowDownTime")):
#			$slowTimeDuration.start()
			changeTimeScale(1.0 * 1/timeScalingFactor, durationPlaceholder, true)

func reverseTime():
	Global.set_timeMultiplier(-1, durationPlaceholder)
func _on_reverseTimeDuration_timeout():
	Global.set_timeMultiplier(-1, 0)
#	musicAttackController.get_node("MusicHandler").timeHasReversedBack()

func stopTime():
#	musicAttackController.get_node("MusicHandler").timeHasStopped($stopTimeDuration.wait_time)
	Global.set_timeFlow(false, durationPlaceholder)
func _on_stopTimeDuration_timeout():
	resumeTime()
func resumeTime():
	Global.set_timeFlow(true, 0)
#	musicAttackController.get_node("MusicHandler").timeHasResumed()
	
func changeTimeScale(timeMultiplier : float, duration : float, startOfDistortion : bool):
	Global.set_timeMultiplier(timeMultiplier, duration)
#	musicAttackController.get_node("MusicHandler").syncPitchWithGlobal(duration, startOfDistortion)
func _on_speedTimeDuration_timeout():
	changeTimeScale(1.0 * 1/timeScalingFactor, 0, false)
func _on_slowTimeDuration_timeout():
	changeTimeScale(timeScalingFactor, 0, false)
