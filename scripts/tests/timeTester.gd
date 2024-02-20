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
		elif(event.is_action_pressed("dash")):
			$TimeSyncedTimer.start()

func _process(delta):
	$TimeSyncedTimer/ProgressBar.value = ($TimeSyncedTimer.time_left / $TimeSyncedTimer.wait_time) *100

func reverseTime():
	Global.changeTimeSpeed(-1, false, durationPlaceholder, false)
func _on_reverseTimeDuration_timeout():
	Global.changeTimeSpeed(-1, false, 0, false)
#	musicAttackController.get_node("MusicHandler").timeHasReversedBack()

func stopTime():
	if Global.timeIsNotStopped: 	Global.startOrStopTime(false, durationPlaceholder, false)
	else: resumeTime()
#	musicAttackController.get_node("MusicHandler").timeHasStopped($stopTimeDuration.wait_time)
func _on_stopTimeDuration_timeout():
	resumeTime()
func resumeTime():
	Global.startOrStopTime(true, 0, false)
#	musicAttackController.get_node("MusicHandler").timeHasResumed()
	
func changeTimeScale(timeMultiplier : float, duration : float, startOfDistortion : bool):
	Global.changeTimeSpeed(timeMultiplier, false, duration, false)
#	musicAttackController.get_node("MusicHandler").syncPitchWithGlobal(duration, startOfDistortion)
func _on_speedTimeDuration_timeout():
	changeTimeScale(1.0 * 1/timeScalingFactor, 0, false)
func _on_slowTimeDuration_timeout():
	changeTimeScale(timeScalingFactor, 0, false)


func _on_time_synced_timer_timeout():
	print("TIMEOUT")


func _on_time_synced_timer_timer_start_undone():
	print("TIMEIN")


func _on_time_synced_timer_tree_entered():
	print("tree entered signal")
