extends Node2D

export var enemyScene : PackedScene
var enemy
var enemyAttackPatternJson #File object
var attackPatternData = [] #string
var currAttack = 1 #int representing current line in json file
var loopStart = 1
var loopEnd = 2
var enemyBulletScene #packed scene of the enemys chosen bullet
var bullet
var currTimeMultiplier : float = 1 # keeps track of current time rate, will NEVER BE 0 THO
var timeIsStopped = false

var maxTimeJuiceSeconds : float = 10
var currTimeJuice : float = 0
var timeJuiceCost : float = 5




func _ready(): #this script sets up enemy, approach() function will handle the rest
	enemy = enemyScene.instance()
	enemy.position = $enemySpawnLocation.position
	enemy.visible = false
	add_child(enemy) # add node to scene
	
	 # connect the signal to start fight from the new node to this one
	# enemy.connect("startFight", self, "_on_BattleModeEnemy_startFight")
	# get the bullet from the enemy so we can spawn it
	enemyBulletScene = enemy.bulletScene
	
	enemy.approach()

var timerCount = 0
func _process(delta):
	pass
func incrementAbilityTimes(delta): 
	$UI/ProgressBar.value = 1.0 * currTimeJuice/maxTimeJuiceSeconds * 100
	if currTimeMultiplier < 0: # if time is reversed, decrease time juice
		currTimeJuice -= delta
	if abs(currTimeMultiplier) > 1: # if time is fast, decrease time juice
		currTimeJuice -= delta
	if currTimeJuice < maxTimeJuiceSeconds and currTimeMultiplier == 1: # only regain the juice during normal time
		currTimeJuice += delta
	

func _input(event):
	print(Global.timeIsNotStopped as int)
	if($AbilityCoolDownTimer.time_left > 0):
		return
	if(event.is_action_pressed("reverseTime")):
		reverseTime()
	elif(event.is_action_pressed("stopTime")):
		if Global.timeIsNotStopped:
			stopTime()
		else:
			resumeTime()
	elif(event.is_action_pressed("speedUpTime")):
		changeTimeScale(2)
	elif(event.is_action_pressed("slowDownTime")):
		changeTimeScale(1.0 * 1/2)
		
func reverseTime():
	Global.set_timeMultiplier(-1)
	$AbilityCoolDownTimer.start()
	currTimeJuice -= timeJuiceCost
	
	$Clock.visible = true
	$Clock.play("forward", currTimeMultiplier<0)
func stopTime():
	$AbilityCoolDownTimer.start()
	Global.set_timeFlow(false)
	currTimeJuice -= timeJuiceCost
	$Clock.visible = true
	$Clock.stop()
func resumeTime():
	$AbilityCoolDownTimer.start()
	Global.set_timeFlow(true)
	currTimeJuice -= timeJuiceCost
	$Clock.visible = true
	$Clock.play()
func changeTimeScale(timeMultiplier : float):
	Global.set_timeMultiplier(timeMultiplier)
	$AbilityCoolDownTimer.start()
	currTimeJuice -= timeJuiceCost
	$Clock.visible = true
	$Clock.speed_scale = currTimeMultiplier
func _on_AbilityCoolDownTimer_timeout():
	$Clock.visible = false


#SIGNALS FROM ENEMY
var overWorldPath = "res://scenes/World.tscn"

func on_attack_phase_starting():
	pass
func on_attack_phase_ending():
	pass
func on_enemyDead():
	$VictoryButton.visible = true
	$VictoryButton.disabled = false
func _on_VictoryButton_pressed():
	var _PTS = get_tree().change_scene(overWorldPath)


