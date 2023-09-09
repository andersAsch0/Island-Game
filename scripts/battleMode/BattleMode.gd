extends Node2D

export var enemyScene : PackedScene
var enemy # reference to the node in the scene tree
var controllerScene : PackedScene
var musicAttackController # reference to the node 
var enemyAttackPatternJson #File object
var attackPatternData = [] #string
var currAttack = 1 #int representing current line in json file
var loopStart = 1
var loopEnd = 2
var bullet
var currTimeMultiplier : float = 1 # keeps track of current time rate, will NEVER BE 0 THO
var timeIsStopped = false
var maxTimeJuiceSeconds : float = 10
var currTimeJuice : float = maxTimeJuiceSeconds
var timeJuiceCost : float = 4
var timeScalingFactor = 2 # ratio by which time speeds or slows
enum{
	DEFENSE
	OFFENSE
	STOPPEDTIME
}
var currState = OFFENSE

signal enemyAttackPhaseStarting
signal enemyAbscondPhaseStarting
signal enemyAwayPhaseStarting
signal enemyApproachPhaseStarting
signal enemyAngleChangePhaseStarting


func _ready(): #this script sets up enemy, approach() function will handle the rest
	Global.currCombatTimeMultiplier = 1
	$offenseModeCamera/PlayerHPBar.value = 1.0 * $BattleModePlayer.currentHP / $BattleModePlayer.maxHP * 100
	updateTimeJuiceBar()
	
	enemyScene = load(Global.battleModeEnemyPath)
	controllerScene = load(Global.musicAttackControllerPath)
	enemy = enemyScene.instance()
	enemy.position = $enemySpawnLocation.position
	enemy.visible = false #node's func, where to, where to's func
	enemy.connect("attackPhaseStarting", self, "on_attack_phase_starting")
	enemy.connect("abscondPhaseStarting", self, "on_abscond_phase_starting")
	enemy.connect("awayPhaseStarting", self, "on_away_phase_starting")
	enemy.connect("approachPhaseStarting", self, "on_approach_phase_starting")
	enemy.connect("angleChangePhaseStarting", self, "on_angle_change_phase_starting")
	enemy.connect("enemyMoved", $BigGridPerspective/enemyGridHighlight, "on_enemyMoved")
	enemy.connect("enemyMoved", $offenseModeCamera/Arrows, "on_enemyMoved")
	enemy.connect("enemyDead", self, "on_enemyDead")
	musicAttackController = controllerScene.instance()
	connect("enemyAttackPhaseStarting", musicAttackController, "defenseModeStarting")
	connect("enemyAbscondPhaseStarting", musicAttackController, "offenseModeStarting")
	musicAttackController.position = Vector2(0,10) # this being hard coded is stupid. but idk how to do it better
	add_child_below_node($offenseModeCamera, enemy)
	$offenseModeCamera.add_child_below_node($offenseModeCamera/Grid, musicAttackController)
	on_away_phase_starting()
	
	 # connect the signal to start fight from the new node to this one
	# enemy.connect("startFight", self, "_on_BattleModeEnemy_startFight")
	

func _process(_delta):
	pass
func incrementAbilityTimes(_delta): 
	updateTimeJuiceBar()
#	if currTimeMultiplier < 0: # if time is reversed, decrease time juice
#		currTimeJuice -= delta
#	if abs(currTimeMultiplier) > 1: # if time is fast, decrease time juice
#		currTimeJuice -= delta
#	if currTimeJuice < maxTimeJuiceSeconds and currTimeMultiplier == 1: # only regain the juice during normal time
#		currTimeJuice += delta
#

func _input(event):
	if currState == DEFENSE:
		if(currTimeJuice < timeJuiceCost):
			return
		if(event.is_action_pressed("reverseTime") and $reverseTimeDuration.time_left == 0):
			$reverseTimeDuration.start()
			currTimeJuice -= timeJuiceCost
			musicAttackController.get_node("MusicHandler").timeHasReversed()		
			reverseTime()
		elif(event.is_action_pressed("stopTime") and $stopTimeDuration.time_left == 0):
			$stopTimeDuration.start()
			currTimeJuice -= timeJuiceCost
			stopTime()
		elif(event.is_action_pressed("speedUpTime") and $speedTimeDuration.time_left == 0):
			$speedTimeDuration.start()
			currTimeJuice -= timeJuiceCost
			changeTimeScale(timeScalingFactor)
		elif(event.is_action_pressed("slowDownTime") and $slowTimeDuration.time_left == 0):
			$slowTimeDuration.start()
			currTimeJuice -= timeJuiceCost
			changeTimeScale(1.0 * 1/timeScalingFactor)
	else: #is offense phase or time stopped
		if(event.is_action_pressed("windWatch")):
			_on_WindWatchButton_pressed()
		elif(event.is_action_pressed("heal")):
			_on_HealButton_pressed()
		elif(event.is_action_pressed("attack")):
			_on_AttackButton_pressed()
		elif(event.is_action_pressed("sheild")):
			_on_ShieldButton_pressed()
		
		
func reverseTime():
	Global.set_timeMultiplier(-1)
	updateTimeJuiceBar()
func _on_reverseTimeDuration_timeout():
	reverseTime()
	musicAttackController.get_node("MusicHandler").timeHasReversedBack()

func stopTime():
	musicAttackController.get_node("MusicHandler").timeHasStopped()
	Global.set_timeFlow(false)
	updateTimeJuiceBar()
	currState = STOPPEDTIME
	showActionMenu(true, false)
func _on_stopTimeDuration_timeout():
	resumeTime()
func resumeTime():
	Global.set_timeFlow(true)
	updateTimeJuiceBar()
	currState = DEFENSE
	showActionMenu(false, false)
	musicAttackController.get_node("MusicHandler").timeHasResumed()
	
func changeTimeScale(timeMultiplier : float):
	Global.set_timeMultiplier(timeMultiplier)
	updateTimeJuiceBar()
	musicAttackController.get_node("MusicHandler").syncPitchWithGlobal()
func _on_speedTimeDuration_timeout():
	changeTimeScale(1.0 * 1/timeScalingFactor)
func _on_slowTimeDuration_timeout():
	changeTimeScale(timeScalingFactor)


	

#SIGNALS FROM ENEMY (controlling current state of battleMode)
export var overWorldPath = "res://scenes/World.tscn"
func on_attack_phase_starting():
	emit_signal("enemyAttackPhaseStarting")
func on_abscond_phase_starting():
	emit_signal("enemyAbscondPhaseStarting")
func on_away_phase_starting():
	emit_signal("enemyAwayPhaseStarting")
	switchToOffenseMode()
func on_approach_phase_starting():
	emit_signal("enemyApproachPhaseStarting")
	$offenseModeCamera/Arrows.visible = false
func on_angle_change_phase_starting():
	emit_signal("enemyAngleChangePhaseStarting")
	switchToDefenseMode()

func switchToDefenseMode():
	currState = DEFENSE
	$offenseModeCamera/Grid.visible = true
	$BigGridPerspective.visible = false
	showActionMenu(false, false)
	$offenseModeCamera.setFollow(false)
	$offenseModeCamera.snapToPlayer()
func switchToOffenseMode():
	currState = OFFENSE
	$offenseModeCamera/Grid.visible = false
	$BigGridPerspective.visible = true
	$offenseModeCamera/Arrows.visible = true
	showActionMenu(true, true)

func on_enemyDead():
	$offenseModeCamera/VictoryButton.visible = true
	$offenseModeCamera/VictoryButton.disabled = false
func _on_VictoryButton_pressed():
	var _PTS = get_tree().change_scene(overWorldPath)

#SIGNALS FROM PLAYER
func _on_BattleModePlayer_PlayerHit():
	$offenseModeCamera/PlayerHPBar.value = 1.0 * $BattleModePlayer.currentHP / $BattleModePlayer.maxHP * 100

func _on_BattleModePlayer_PlayerDie():
	$offenseModeCamera/DefeatButton.visible = true
	$offenseModeCamera/DefeatButton.disabled = false
	set_block_signals(true)
	get_tree().call_group("enemies", "playerDie")
	
func _on_DefeatButton_pressed():
	var _PTS = get_tree().change_scene(overWorldPath)


#ACTIONS
func showActionMenu(showMenu : bool, showArrows : bool):
	$offenseModeCamera/Arrows.visible = showArrows
	$offenseModeCamera/actionMenu.play("hide", showMenu)
enum { RIGHT, LEFT, UP, DOWN }
var moveVectors : PoolVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]

func updateTimeJuiceBar():
	$offenseModeCamera/TimeJuiceBar.value = 1.0 * currTimeJuice/maxTimeJuiceSeconds * 100
func _on_WindWatchButton_pressed():
	$BattleModePlayer.windWatchButtonPressed()
	print("camera : ", $offenseModeCamera.position, " player: ", $BattleModePlayer.position)
func _on_windWatchMiniGame_wind(timeJuiceChange):
	currTimeJuice += timeJuiceChange
	if currTimeJuice > maxTimeJuiceSeconds:
		currTimeJuice = maxTimeJuiceSeconds
	updateTimeJuiceBar()
func _on_HealButton_pressed():
	$BattleModePlayer.healButtonPressed()
func _on_AttackButton_pressed():
	$BattleModePlayer.attackButtonPressed()
func _on_ShieldButton_pressed():
	$BattleModePlayer.shield()
#	$offenseModeCamera/Arrows.visible = false







