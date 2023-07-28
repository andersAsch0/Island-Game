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
var isDefensePhase = false # referring to the player: enemy is attacking during defense phase



func _ready(): #this script sets up enemy, approach() function will handle the rest
	Global.currCombatTimeMultiplier = 1
	enemyScene = load(Global.battleModeEnemyPath)
	$normalMusicLoop.play()
	$reverseMusicLoop.play()
	$reverseMusicLoop/tickingClockFX.play()
	$PlayerHPBar.value = $BattleModePlayer.currentHP
	enemy = enemyScene.instance()
	enemy.position = $enemySpawnLocation.position
	enemy.visible = false
	add_child(enemy) # add node to scene
	
	 # connect the signal to start fight from the new node to this one
	# enemy.connect("startFight", self, "_on_BattleModeEnemy_startFight")
	# get the bullet from the enemy so we can spawn it
	enemyBulletScene = enemy.bulletScene

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
	if($AbilityCoolDownTimer.time_left > 0 or not isDefensePhase):
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
	$reverseMusicLoop/reverseStartFX.play()
	$normalMusicLoop.stream_paused = Global.currCombatTimeMultiplier < 0
	$reverseMusicLoop.stream_paused = not Global.currCombatTimeMultiplier < 0
	$reverseMusicLoop/tickingClockFX.stream_paused = not Global.currCombatTimeMultiplier < 0
	$AbilityCoolDownTimer.start()
	currTimeJuice -= timeJuiceCost
	
	$Clock.visible = true
	$Clock.play("forward", currTimeMultiplier<0)
func stopTime():
	toggleMusic()
	$AbilityCoolDownTimer.start()
	Global.set_timeFlow(false)
	currTimeJuice -= timeJuiceCost
	$Clock.visible = true
	$Clock.stop()
func resumeTime():
	toggleMusic()
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
	setMusicPitchScaleToGlobal()
func _on_AbilityCoolDownTimer_timeout():
	$Clock.visible = false


#SIGNALS FROM ENEMY
export var overWorldPath = "res://scenes/World.tscn"
func on_attack_phase_starting():
	isDefensePhase = true
func on_attack_phase_ending():
	isDefensePhase = false
func on_enemyDead():
	$VictoryButton.visible = true
	$VictoryButton.disabled = false
func _on_VictoryButton_pressed():
	var _PTS = get_tree().change_scene(overWorldPath)


#SIGNALS FROM PLAYER
func _on_BattleModePlayer_PlayerHit():
	$PlayerHPBar.value = 1.0 * $BattleModePlayer.currentHP / $BattleModePlayer.maxHP * 100
	if $BattleModePlayer.currentHP <= 0:
		playerDie()

func playerDie():
	$DefeatButton.visible = true
	$DefeatButton.disabled = false
	get_tree().call_group("enemies", "stopBullets")
func _on_DefeatButton_pressed():
	var _PTS = get_tree().change_scene(overWorldPath)

#MUSIC
func _on_normalMusicLoop_finished():
	$normalMusicLoop.play(0)
func _on_reverseAudioLoop_finished():
	$reverseAudioLoop.play(0)
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
