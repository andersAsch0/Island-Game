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
var currTimeJuice : float = maxTimeJuiceSeconds
var timeJuiceCost : float = 4
var timeScalingFactor = 2 # ratio by which time speeds or slows
enum{
	DEFENSE
	OFFENSE
	STOPPEDTIME
}
var currState = OFFENSE

signal offensePhaseStarting
signal offensePhaseEnding


func _ready(): #this script sets up enemy, approach() function will handle the rest
	Global.currCombatTimeMultiplier = 1
	enemyScene = load(Global.battleModeEnemyPath)
	$normalMusicLoop.play()
	$reverseMusicLoop.play()
	$reverseMusicLoop/tickingClockFX.play()
	$offenseModeCamera/PlayerHPBar.value = 1.0 * $BattleModePlayer.currentHP / $BattleModePlayer.maxHP * 100
	updateTimeJuiceBar()
	enemy = enemyScene.instance()
	enemy.position = $enemySpawnLocation.position
	enemy.visible = false
	enemy.connect("enemyMoved", $BigGridPerspective/enemyGridHighlight, "on_enemyMoved")
	enemy.connect("enemyMoved", $offenseModeCamera/Arrows, "on_enemyMoved")
	add_child(enemy) # add node to scene
	on_attack_phase_ending() #battles start in offense mode for the player
	
	 # connect the signal to start fight from the new node to this one
	# enemy.connect("startFight", self, "_on_BattleModeEnemy_startFight")
	# get the bullet from the enemy so we can spawn it
	enemyBulletScene = enemy.bulletScene
	

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
	$reverseMusicLoop/reverseStartFX.play()
	$normalMusicLoop.stream_paused = Global.currCombatTimeMultiplier < 0
	$reverseMusicLoop.stream_paused = not Global.currCombatTimeMultiplier < 0
	$reverseMusicLoop/tickingClockFX.stream_paused = not Global.currCombatTimeMultiplier < 0
	updateTimeJuiceBar()
func _on_reverseTimeDuration_timeout():
	reverseTime()

func stopTime():
	toggleMusic()
	Global.set_timeFlow(false)
	updateTimeJuiceBar()
	currState = STOPPEDTIME
	showActionMenu(true, false)
func _on_stopTimeDuration_timeout():
	resumeTime()
func resumeTime():
	toggleMusic()
	Global.set_timeFlow(true)
	updateTimeJuiceBar()
	currState = DEFENSE
	showActionMenu(false, false)
	
func changeTimeScale(timeMultiplier : float):
	Global.set_timeMultiplier(timeMultiplier)
	updateTimeJuiceBar()
	setMusicPitchScaleToGlobal()
func _on_speedTimeDuration_timeout():
	changeTimeScale(1.0 * 1/timeScalingFactor)
func _on_slowTimeDuration_timeout():
	changeTimeScale(timeScalingFactor)


	

#SIGNALS FROM ENEMY
export var overWorldPath = "res://scenes/World.tscn"
func on_attack_phase_starting():
	emit_signal("offensePhaseEnding")
	currState = DEFENSE
	$offenseModeCamera/Grid.visible = true
	$BigGridPerspective.visible = false
	showActionMenu(false, false)
	$offenseModeCamera.setFollow(false)
	$offenseModeCamera.snapToPlayer()
func on_attack_phase_ending():
	emit_signal("offensePhaseStarting")
	currState = OFFENSE
	$offenseModeCamera/Grid.visible = false
	$BigGridPerspective.visible = true
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

#MUSIC
func _on_normalMusicLoop_finished():
	$normalMusicLoop.play(0)
func _on_reverseAudioLoop_finished():
	$reverseMusicLoop.play(0)
func _on_tickingClockFX_finished():
	$reverseMusicLoop/tickingClockFX.play(0)
func toggleMusic():
	$normalMusicLoop.playing = not Global.timeIsNotStopped #what thee heck
	$reverseMusicLoop.playing = not Global.timeIsNotStopped
	$reverseMusicLoop/tickingClockFX.stop()
	$reverseMusicLoop/reverseStartFX.stop()
func setMusicPitchScaleToGlobal():
	$normalMusicLoop.pitch_scale = abs(Global.currCombatTimeMultiplier)
	$reverseMusicLoop.pitch_scale = abs(Global.currCombatTimeMultiplier)
	$reverseMusicLoop/tickingClockFX.pitch_scale = abs(Global.currCombatTimeMultiplier)
	$reverseMusicLoop/reverseStartFX.pitch_scale = abs(Global.currCombatTimeMultiplier)


#ACTIONS
func showActionMenu(showMenu : bool, showArrows : bool):
	$offenseModeCamera/Arrows.visible = showArrows
	$offenseModeCamera/actionMenu.play("hide", showMenu)
enum { RIGHT, LEFT, UP, DOWN }
var moveVectors : PoolVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]

func updateTimeJuiceBar():
	$offenseModeCamera/TimeJuiceBar.value = 1.0 * currTimeJuice/maxTimeJuiceSeconds * 100
func _on_WindWatchButton_pressed():
	$BattleModePlayer.startWindWatch()
	$BattleModePlayer/watchWindTimer.start()
func _on_watchWindTimer_timeout():
	if $BattleModePlayer.finishWindWatch():
		currTimeJuice += timeJuiceCost
		if currTimeJuice > maxTimeJuiceSeconds:
			currTimeJuice = maxTimeJuiceSeconds
		updateTimeJuiceBar()
func _on_HealButton_pressed():
	$BattleModePlayer.startHeal()
	$BattleModePlayer/HealTimer.start()
func _on_HealTimer_timeout():
	$BattleModePlayer.finishHeal(1)
func _on_AttackButton_pressed():
	$BattleModePlayer.startAttack(1)
func _on_ShieldButton_pressed():
	$BattleModePlayer.shield()

