extends CanvasLayer

signal sheildActivated
signal winding(activated)
signal healing(activated)
signal attacking(activated)

signal caughtHeal(HPHealed)
signal attackHit(HPHit)
signal watchWind(timeJuiceChange)

signal minigameActiveUpdate(active)

var actionsActive : bool = true
var sheildActive : bool = false

func _on_BattleMode_enemyAwayPhaseStarting():
	actionsActive = true
	sheildActive = false
	updateMiniGameActive()
	enableActionButtons(true, true, true, true)

func _on_BattleMode_enemyAngleChangePhaseStarting():
	actionsActive = false
	deactivateButtonsAndGames(false, false, false)
	enableActionButtons(false, false, false, false)

func enableActionButtons(enableWind: bool, enableAttack : bool, enableHeal : bool, enableSheild : bool):
	$windButton.showButton(enableWind)
	$attackButton.showButton(enableAttack)
	$healButton.showButton(enableHeal)
	$sheildButton.showButton(enableSheild)

#move hp and tj bar to UI layer and link up
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

func sheildButtonPressed(): #not a toggle (yet)
	if sheildActive or not actionsActive:
		return
	sheildActive = true
	$sheildButton.activate(true)
	deactivateButtonsAndGames(false, false, false)
	enableActionButtons(false, false, false, true)
	updateMiniGameActive()
	emit_signal("sheildActivated")


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
