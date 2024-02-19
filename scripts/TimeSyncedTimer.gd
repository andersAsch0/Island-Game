class_name TimeSyncedTimer
extends Node

@export var wait_time : float = 1
@export var time_left : float = -1
@export var one_shot : bool = false
@export var autostart : bool = false
var paused : bool = false
var running : bool = false
signal timeout()
##if time reverses back to before the timer was started
signal timerStartUndone() 

func _ready():
	if time_left < 0: time_left = wait_time #if it hasnt been edited to smth else
	connect("tree_entered", Callable(self, "on_tree_entered"))
	
func on_tree_entered():
	if autostart: start()

func start():
	time_left = wait_time
	running = true
func stop():
	running = false
##continue running without resetting the time left
func resume(): 
	running = true

func _physics_process(delta):
	if running and not paused:
		time_left -= delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	if time_left <= 0: 
		time_left = 0
		running = false
		emit_signal("timeout")
		if not one_shot: start()
	elif  time_left >= wait_time:
		time_left = 0
		running = false
		emit_signal("timerStartUndone")
		if not one_shot: #assuming that if it is a repeating timer, desired behavior is a signal at a specific interval
			emit_signal("timeout")
			running = true

func is_stopped():
	return running
	
