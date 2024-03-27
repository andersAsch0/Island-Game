extends Node2D

@export var enemyScene : PackedScene
var enemy # reference to the node in the scene tree
var controllerScene : PackedScene
var musicAttackController # reference to the node 
var enemyAttackPatternJson #File object
var attackPatternData = [] #string
var currAttack = 1 #int representing current line in json file
var loopStart = 1
var loopEnd = 2
var bullet
var maxTimeJuiceSeconds : float = 100
var currTimeJuice : float = maxTimeJuiceSeconds
var timeJuiceCost : float = 4
var timeScalingFactor = 2 # ratio by which time speeds or slows


signal enemyAttackPhaseStarting(duration)
signal enemyAbscondPhaseStarting(duration)
signal enemyAwayPhaseStarting(duration)
signal enemyApproachPhaseStarting(duration)
signal enemyAngleChangePhaseStarting(duration)

#
#signal timeStopped
#signal timeResumed
#signal timeReversed
#signal timeScaleChanged(factor)

#Battlemode todo: (hopefully)
#make time distortion work in anglechange and abscond phases (current issue: big grid frame rate)
#get time distortion to effect: enemy state counter, other time distortions counters
# maybe even work during offense ???? cant effect minigames i think bc then what would happen when u stop time during defense
# also i think the idea is that amadeus isnt effected. but it could effect the enemeys state counter
#redo time system to work on signals, (above) instead of cluttering up with manual calls to every damn random thing
#maybe just redo time system idk, having some of them be toggles and other not is dumb and annoying

func _ready(): #this script sets up enemy, approach() function will handle the rest
	Global.currCombatTimeMultiplier = 1
	_on_BattleModePlayer_PlayerHit()
	updateTimeJuiceBar()
	
	if(Global.battleModeEnemyPath != ""):	
		enemyScene = load(Global.battleModeEnemyPath)
		enemy = enemyScene.instantiate()
		enemy.position = $enemySpawnLocation.position
		enemy.visible = false #node's func, where to, where to's func
		enemy.connect("attackPhaseStarting", Callable(self, "on_attack_phase_starting"))
		enemy.connect("abscondPhaseStarting", Callable(self, "on_abscond_phase_starting"))
		enemy.connect("awayPhaseStarting", Callable(self, "on_away_phase_starting"))
		enemy.connect("approachPhaseStarting", Callable(self, "on_approach_phase_starting"))
		enemy.connect("angleChangePhaseStarting", Callable(self, "on_angle_change_phase_starting"))
		enemy.connect("enemyMoved", Callable($offenseModeCamera/Arrows, "on_enemyMoved"))
		enemy.connect("enemyDead", Callable(self, "on_enemyDead"))
	#musicAttackController = controllerScene.instantiate()
	#connect("enemyAttackPhaseStarting", Callable(musicAttackController, "on_BattleMode_defense_mode"))
	#connect("enemyAbscondPhaseStarting", Callable(musicAttackController, "on_BattleMode_offense_mode"))
	#connect("enemyAngleChangePhaseStarting", Callable(musicAttackController, "on_BattleMode_offense_mode"))
#	#TODO: make the music attack controller a child of the enemy

#
#
	#musicAttackController.position = Vector2(0,10) # this being hard coded is stupid. but idk how to do it better
	
	$offenseModeCamera.add_sibling(enemy, false)
	#$offenseModeCamera/Grid.add_sibling(musicAttackController)
	on_away_phase_starting(0) #hope this doesnt break something in hte future!!! hahaha!!!!
	
	
func incrementAbilityTimes(_delta): 
	updateTimeJuiceBar()

func _input(event):
#	if currState != OFFENSE: #is defense phase or time stopped
	if(currTimeJuice < timeJuiceCost):
		return
	if(event.is_action_pressed("reverseTime") and $reverseTimeDuration.time_left == 0):
		$reverseTimeDuration.start()
#			musicAttackController.get_node("MusicHandler").timeHasReversed($reverseTimeDuration.wait_time)		
		reverseTime()
	elif(event.is_action_pressed("stopTime") and $stopTimeDuration.time_left == 0):
		$stopTimeDuration.start()
		stopTime()
	elif(event.is_action_pressed("speedUpTime") and $speedTimeDuration.time_left == 0):
		$speedTimeDuration.start()
		speedTime()
	elif(event.is_action_pressed("slowDownTime") and $slowTimeDuration.time_left == 0):
		$slowTimeDuration.start()
		slowTime()
	if $UI.actionsActive: #is offense phase or time stopped
		if(event.is_action_pressed("windWatch")):
			$UI.windWatchButtonPressed()
		elif(event.is_action_pressed("heal")):
			$UI.healButtonPressed()
		elif(event.is_action_pressed("attack")):
			$UI.attackButtonPressed()
		elif(event.is_action_pressed("sheild")):
			$UI.sheildButtonPressed()
		

		
func reverseTime():
	Global.reverseTime(true, $reverseTimeDuration.wait_time, true)
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
func _on_reverseTimeDuration_timeout():
	Global.reverseTime(false, $reverseTimeDuration.wait_time, false)

func stopTime():
	Global.startOrStopTime(false, $stopTimeDuration.wait_time, true)
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
func _on_stopTimeDuration_timeout():
	Global.startOrStopTime(true, $stopTimeDuration.wait_time, false)
	
func speedTime():
	Global.changeTimeSpeed(timeScalingFactor, true, $speedTimeDuration.wait_time, true)
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
func _on_speedTimeDuration_timeout():
	Global.changeTimeSpeed(1.0 / timeScalingFactor, true, $speedTimeDuration.wait_time, false)
func slowTime():
	Global.changeTimeSpeed(1.0 / timeScalingFactor, false, $speedTimeDuration.wait_time, true)
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
func _on_slowTimeDuration_timeout():
	Global.changeTimeSpeed(timeScalingFactor, false, $speedTimeDuration.wait_time, false)


	

#SIGNALS FROM ENEMY (controlling current state of battleMode)
@export var overWorldPath = "res://scenes/World.tscn"
func on_attack_phase_starting(duration):
	#musicAttackController.rotateWithEnemy()
	emit_signal("enemyAttackPhaseStarting", duration)
	cameraFollow(false)
func on_abscond_phase_starting(duration):
	emit_signal("enemyAbscondPhaseStarting", duration)
	cameraFollow(true)
func on_away_phase_starting(duration):
	emit_signal("enemyAwayPhaseStarting", duration)
	cameraFollow(true)
func on_approach_phase_starting(duration):
	emit_signal("enemyApproachPhaseStarting", duration)
	cameraFollow(true)
func on_angle_change_phase_starting(duration):
	emit_signal("enemyAngleChangePhaseStarting", duration)
	cameraFollow(false)


func cameraFollow(enable : bool):
	$offenseModeCamera.setFollow(enable)
#	$offenseModeCamera.snapToPlayer()
func cameraStatic():
	pass

func on_enemyDead():
	$offenseModeCamera/VictoryButton.visible = true
	$offenseModeCamera/VictoryButton.disabled = false
	Global.battleModeEnemyDefeated()
func _on_VictoryButton_pressed():
	Global.reEnterOverworld()

#SIGNALS FROM PLAYER
func _on_BattleModePlayer_PlayerHit():
	$UI/PlayerHPBar.value = 1.0 * $BattleModePlayer.currentHP / $BattleModePlayer.maxHP * 100

func _on_BattleModePlayer_PlayerDie():
	$offenseModeCamera/DefeatButton.visible = true
	$offenseModeCamera/DefeatButton.disabled = false
	set_process_input(false)
	get_tree().call_group("enemies", "playerDie")
	
func _on_DefeatButton_pressed():
	Global.reEnterOverworld()


#ACTIONS
func showActionMenu(showAttack : bool, showHeal : bool, showWind : bool, showSheild: bool, showArrows : bool):
	$offenseModeCamera/Arrows.visible = showArrows
	$UI/attackButton.showButton(showAttack)
	$UI/healButton.showButton(showHeal)
	$UI/windButton.showButton(showWind)
	$UI/sheildButton.showButton(showSheild)
enum { RIGHT, LEFT, UP, DOWN }
var moveVectors : PackedVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]

func updateTimeJuiceBar():
	$UI/TimeJuiceBar.value = 1.0 * currTimeJuice/maxTimeJuiceSeconds * 100
func _on_windWatchMiniGame_wind(timeJuiceChange):
	currTimeJuice += timeJuiceChange
	if currTimeJuice > maxTimeJuiceSeconds:
		currTimeJuice = maxTimeJuiceSeconds
	updateTimeJuiceBar()









