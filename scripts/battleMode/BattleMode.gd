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
var isDefensePhase = false # referring to the player: enemy is attacking during defense phase

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
	add_child(enemy) # add node to scene
	on_attack_phase_ending() #battles start in offense mode for the player
	updateAllArrows()
	
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
	if isDefensePhase:
		if($AbilityCoolDownTimer.time_left > 0):
			return
		if(event.is_action_pressed("reverseTime") and currTimeJuice > timeJuiceCost):
			reverseTime()
		elif(event.is_action_pressed("stopTime") and currTimeJuice > timeJuiceCost):
			if Global.timeIsNotStopped:
				stopTime()
			else:
				resumeTime()
		elif(event.is_action_pressed("speedUpTime") and currTimeJuice > timeJuiceCost):
			changeTimeScale(2)
		elif(event.is_action_pressed("slowDownTime") and currTimeJuice > timeJuiceCost):
			changeTimeScale(1.0 * 1/2)
	else: #is offense phase
		if(event.is_action_pressed("windWatch")):
			_on_WindWatchButton_pressed()
		elif(event.is_action_pressed("heal")):
			_on_HealButton_pressed()
		elif(event.is_action_pressed("attack")):
			_on_AttackButton_pressed()
		elif(event.is_action_pressed("shield")):
			_on_ShieldButton_pressed()
		
		
func reverseTime():
	Global.set_timeMultiplier(-1)
	$reverseMusicLoop/reverseStartFX.play()
	$normalMusicLoop.stream_paused = Global.currCombatTimeMultiplier < 0
	$reverseMusicLoop.stream_paused = not Global.currCombatTimeMultiplier < 0
	$reverseMusicLoop/tickingClockFX.stream_paused = not Global.currCombatTimeMultiplier < 0
	$AbilityCoolDownTimer.start()
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
	
	$Clock.visible = true
	$Clock.play("forward", currTimeMultiplier<0)
func stopTime():
	toggleMusic()
	$AbilityCoolDownTimer.start()
	Global.set_timeFlow(false)
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
	$Clock.visible = true
	$Clock.stop()
func resumeTime():
	toggleMusic()
	$AbilityCoolDownTimer.start()
	Global.set_timeFlow(true)
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
	$Clock.visible = true
	$Clock.play()
func changeTimeScale(timeMultiplier : float):
	Global.set_timeMultiplier(timeMultiplier)
	$AbilityCoolDownTimer.start()
	currTimeJuice -= timeJuiceCost
	updateTimeJuiceBar()
	$Clock.visible = true
	$Clock.speed_scale = currTimeMultiplier
	setMusicPitchScaleToGlobal()
func _on_AbilityCoolDownTimer_timeout():
	$Clock.visible = false
	

#SIGNALS FROM ENEMY
export var overWorldPath = "res://scenes/World.tscn"
func on_attack_phase_starting():
	emit_signal("offensePhaseEnding")
	isDefensePhase = true
	$offenseModeCamera/Grid.visible = true
	$bigGrid.visible = false
	showActionMenu(false)
	$offenseModeCamera.setFollow(false)
func on_attack_phase_ending():
	emit_signal("offensePhaseStarting")
	isDefensePhase = false
	$offenseModeCamera/Grid.visible = false
	$bigGrid.visible = true
	showActionMenu(true)
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
func showActionMenu(show : bool):
	$BattleModePlayer/Arrows.visible = show
	$BattleModePlayer/Arrows/downArrow/moveButton.set_deferred("disabled", not show)
	$BattleModePlayer/Arrows/upArrow/moveButton.set_deferred("disabled", not show)
	$BattleModePlayer/Arrows/leftArrow/moveButton.set_deferred("disabled", not show)
	$BattleModePlayer/Arrows/rightArrow/moveButton.set_deferred("disabled", not show)
	$BattleModePlayer/actionMenu.play("hide", show)
enum { RIGHT, LEFT, UP, DOWN }
var moveVectors : PoolVector2Array = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1)]
func _on_downMoveButton_pressed():
	$offenseModeCamera.setFollow(true)
	if canMoveTo($BattleModePlayer.currentGridSquare + moveVectors[DOWN]):
		$BattleModePlayer.move(DOWN)	
	updateAllArrows()
func _on_upMoveButton_pressed():
	$offenseModeCamera.setFollow(true)
	if canMoveTo($BattleModePlayer.currentGridSquare + moveVectors[UP]):
		$BattleModePlayer.move(UP)	
	updateAllArrows()
func _on_rightMoveButton_pressed():
	$offenseModeCamera.setFollow(true)
	if canMoveTo($BattleModePlayer.currentGridSquare + moveVectors[RIGHT]):
		$BattleModePlayer.move(RIGHT)	
	updateAllArrows()
func _on_leftMoveButton_pressed():
	$offenseModeCamera.setFollow(true)
	if canMoveTo($BattleModePlayer.currentGridSquare + moveVectors[LEFT]):
		$BattleModePlayer.move(LEFT)	
	updateAllArrows()
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

func canMoveTo(gridLocation : Vector2):
	var enemy = get_tree().get_nodes_in_group("enemies")
	var enemySquare = enemy[0].getCurrGridSquare()
	if gridLocation.x > 4 or gridLocation.x < 0:
		return false
	if gridLocation.y > 4 or gridLocation.y < 0:
		return false
	elif gridLocation == enemySquare:
		return false
	else:
		return true
func updateAllArrows():
	$BattleModePlayer/Arrows/upArrow.updateSelf(UP)
	$BattleModePlayer/Arrows/downArrow.updateSelf(DOWN)
	$BattleModePlayer/Arrows/leftArrow.updateSelf(LEFT)
	$BattleModePlayer/Arrows/rightArrow.updateSelf(RIGHT)

