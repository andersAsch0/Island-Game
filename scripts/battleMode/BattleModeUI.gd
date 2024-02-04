extends CanvasLayer

signal sheildActivated(activated, delaySeconds) #if this stat becomes changable, it w other stats will b taken from global or smth
signal sheildDeactivationComplete()
signal winding(activated)
signal healing(activated)
signal attacking(activated)

signal caughtHeal(HPHealed)
signal attackHit(HPHit)
signal watchWind(timeJuiceChange)

signal minigameActiveUpdate(active)

var actionsActive : bool = true
var sheildActive : bool = false
var enemyIsAway : bool = true

func _ready():
	Global.connect("timeHasStoppedOrStarted", Callable(self, "_on_Global_timeHasStoppedOrStarted"))

func _on_BattleMode_enemyAwayPhaseStarting(_duration):
	enemyIsAway = true
	actionsActive = true
	sheildActive = get_node("../BattleModePlayer").isShielded
	updateMiniGameActive()
	enableActionButtons(not sheildActive, not sheildActive, not sheildActive, true)
	$sheildButton.activate(sheildActive)

func _on_BattleMode_enemyAngleChangePhaseStarting(_duration):
	enemyIsAway = false
	actionsActive = false
	deactivateButtonsAndGames(false, false, false)
	enableActionButtons(false, false, false, false)

func _on_Global_timeHasStoppedOrStarted(_duration, _start):
	if Global.timeIsNotStopped: #if time is flowing
		_on_BattleMode_enemyAngleChangePhaseStarting(0)
	elif !enemyIsAway: # if time has stopped
		_on_BattleMode_enemyAwayPhaseStarting(0)


		

#this is kind of bad bc the games dont get deactivated. i dont want to change it tho. gotta remember to end games first
func enableActionButtons(enableWind: bool, enableAttack : bool, enableHeal : bool, enableSheild : bool):
	$windButton.showButton(enableWind)
	$attackButton.showButton(enableAttack)
	$healButton.showButton(enableHeal)
	$sheildButton.showButton(enableSheild)

#todo: equipping shield is instant, removing it takes time, but you CAN remove it 
func updateMiniGameActive():
	emit_signal("minigameActiveUpdate",  $healButton.active or $windButton.active or $attackButton.active)

func windWatchButtonPressed(): #this is a toggle
	if sheildActive or not actionsActive:
		return
	$windButton/blankButton/windWatchMiniGame.playGame()
	if $windButton/blankButton/windWatchMiniGame.is_processing_input():
		deactivateButtonsAndGames(true, false, false)
	$windButton.activate($windButton/blankButton/windWatchMiniGame.is_processing_input())
	updateMiniGameActive()
	emit_signal("winding", $windButton/blankButton/windWatchMiniGame.is_processing_input())
func _on_windWatchMiniGame_wind():
	emit_signal("watchWind", 1)
func _on_windWatchMiniGame_failedWind():
	emit_signal("watchWind", -1)

	
func healButtonPressed(): #this is a toggle now
	if sheildActive or not actionsActive:
		return
	if not $healButton.active:
		deactivateButtonsAndGames(false, false, true)
		$healButton/blankButton/catchMiniGame.playGame()
		$healButton.activate(true)
	else:
		$healButton.activate(false)
		$healButton/blankButton/catchMiniGame.gameEnd()
	updateMiniGameActive()
	emit_signal("healing", $healButton.active)
func _on_catchMiniGame_caughtHeal():
	updateMiniGameActive()
	emit_signal("caughtHeal", 1)
#	emit_signal("PlayerHit") #update HP bar in parent node
func _on_catchMiniGame_gameEnded():
	$healButton.activate(false)
	updateMiniGameActive()
	emit_signal("healing", false)


func attackButtonPressed(): #this is a toggle
	if sheildActive or not actionsActive:
		return
	$attackButton/blankButton/comboMiniGame.playGame()
	if $attackButton/blankButton/comboMiniGame.is_processing_input():
		deactivateButtonsAndGames(false, true, false)
	$attackButton.activate($attackButton/blankButton/comboMiniGame.is_processing_input())
	updateMiniGameActive()
	emit_signal("attacking", $attackButton/blankButton/comboMiniGame.is_processing_input())
func _on_comboMiniGame_successfulCombo(damage):
	if abs(Global.getEnemyDisplacementFromPlayer().x) <= 1 and abs(Global.getEnemyDisplacementFromPlayer().y) <= 1:
		get_tree().call_group("enemies", "getHit", damage)
		#do enemy damage anim
	else:
		pass
		#do miss anim

var sheildDeactivateDelaySeconds = 1.0
func sheildButtonPressed(): #this is a toggle
	if not actionsActive:
		return
	elif not sheildActive: #activate sheild
		deactivateButtonsAndGames(false, false, false)
		enableActionButtons(false, false, false, true)
		emit_signal("sheildActivated", true, 0.0)
		sheildActive = true
		$sheildButton.activate(true)
		updateMiniGameActive()
	else : #disable shield
		if $sheildDeactivateDelay.time_left == 0: #sheild is already mid-removal
			emit_signal("sheildActivated", false, sheildDeactivateDelaySeconds)
			$sheildDeactivateDelay.wait_time = sheildDeactivateDelaySeconds
			$sheildDeactivateDelay.start()

func _on_sheildDeactivateDelay_timeout():
	enableActionButtons(true, true, true, true)
	sheildActive = false
	$sheildButton.activate(false)
	updateMiniGameActive()
	emit_signal("sheildDeactivationComplete")
	

		
		


func deactivateButtonsAndGames(windOn : bool, attackOn : bool, healOn : bool):
	if not windOn:
		$windButton.activate(false)
		$windButton/blankButton/windWatchMiniGame.gameEnd()
	if not attackOn:
		$attackButton.activate(false)
		$attackButton/blankButton/comboMiniGame.gameEnd()
	if not healOn:
		$healButton.activate(false)
		$healButton/blankButton/catchMiniGame.gameEnd()
	updateMiniGameActive()

