extends Node2D

export var enemyScene : PackedScene
var enemy
var enemyAttackPatternJson #File object
var attackPatternData = [] #string
var currAttack = 1 #int representing current line in json file
var enemyBulletScene #packed scene of the enemys chosen bullet
var bullet
var loopStart = 1
var loopEnd = 2
var currTimeMultiplier = 1 # keeps track of current time rate, will NEVER BE 0 THO
var timeIsStopped = false

var maxTimeJuiceSeconds = 10
var currTimeJuice = maxTimeJuiceSeconds




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
	timerCount += delta
	if(timerCount >= 1):
		timerCount = 0
		incrementAbilityTimes()
	$TimeJuiceBarOutline/TimeJuiceBar.rect_size.x = currTimeJuice/maxTimeJuiceSeconds * $TimeJuiceBarOutline.rect_size.x
func incrementAbilityTimes(): 
	if currTimeMultiplier < 0: # if time is reversed, decrease time juice
		currTimeJuice -= 1
	if abs(currTimeMultiplier) > 1: # if time is fast, decrease time juice
		currTimeJuice -= 1
	if currTimeMultiplier == 1: # only regain the juice during normal time
		currTimeJuice += 1
	

func _input(event):
	if($AbilityCoolDownTimer.time_left > 0):
		return
	if(event.is_action_pressed("reverseTime")):
		reverseTime()
	elif(event.is_action_pressed("stopTime")):
		if not timeIsStopped:
			stopTime()
		else:
			resumeTime()
	elif(event.is_action_pressed("speedUpTime")):
		speedUpTime()
		
func reverseTime():
	get_tree().call_group("bulletTypes", "reverseTime") # reverse direction of ALREADY EXISTING bullets
	get_tree().call_group("enemies", "reverseTime") # reverse direction of all future bullets spawned
	$AbilityCoolDownTimer.start()
	currTimeMultiplier *= -1
	currTimeJuice -= 5
func stopTime():
	get_tree().call_group("bulletTypes", "stopTime")
	get_tree().call_group("enemies", "stopTime")
	$AbilityCoolDownTimer.start()
	timeIsStopped = true
	currTimeJuice -= 5
func resumeTime():
	get_tree().call_group("bulletTypes", "resumeTime")
	get_tree().call_group("enemies", "resumeTime")
	$AbilityCoolDownTimer.start()
	timeIsStopped = false
	currTimeJuice -= 5
func speedUpTime():
	get_tree().call_group("bulletTypes", "speedUpTime", 2) 
	get_tree().call_group("enemies", "speedUpTime", 2)
	$AbilityCoolDownTimer.start()
	currTimeJuice -= 5

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

