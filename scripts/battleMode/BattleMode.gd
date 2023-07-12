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

func _input(event):
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
	currTimeMultiplier *= -1
func stopTime():
	get_tree().call_group("bulletTypes", "stopTime")
	get_tree().call_group("enemies", "stopTime")
	timeIsStopped = true
func resumeTime():
	get_tree().call_group("bulletTypes", "resumeTime")
	get_tree().call_group("enemies", "resumeTime")
	timeIsStopped = false
func speedUpTime():
	get_tree().call_group("bulletTypes", "speedUpTime", 2) 
	get_tree().call_group("enemies", "speedUpTime", 2)

func on_attack_phase_starting():
	print("attack phase starting")
func on_attack_phase_ending():
	print("attack phase ending")
