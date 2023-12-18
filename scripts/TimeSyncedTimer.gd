class_name TimeSyncedTimer
extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var waitTimeReal

# Called when the node enters the scene tree for the first time.
func _ready():
	waitTimeReal = wait_time
	connect("timeout", self, "on_timeout")
	process_mode = TIMER_PROCESS_PHYSICS


#
func _physics_process(delta):#abosutley abusing this poor timer
	
	if not is_stopped() and time_left + (delta - delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)) > 0: 
		start(time_left + (delta - delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)))
#		print(time_left)
		if wait_time > waitTimeReal and Global.currCombatTimeMultiplier < 0:
			if one_shot: stop()
			else: start(delta)
	
func setWaitTime(waittime : float):
	waitTimeReal = waittime

func on_timeout():
	print("timeout")
	if not one_shot: start(waitTimeReal)
#if time is stopped, add delta
#if time is fast, minus (delta * spedUpAmt) - delta
# if time is slow, add delta - (delta * slowness)
# if time is reversed, add delta * 2 (and if it hits wait_time, stop unless looping)

#generalized:

# - ((delta * multiplier) - delta)
# delta - (delta * multiplier)
# delta + delta
# delta - (delta * timeIsflowing as int)

# add delta - (delta * multiplier * timeisFlowing as int)
