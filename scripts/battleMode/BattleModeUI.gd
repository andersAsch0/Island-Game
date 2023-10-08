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

func _on_BattleMode_enemyAngleChangePhaseStarting():
	actionsActive = false

func enableActionButtons(enableWind: bool, enableAttack : bool, enableHeal : bool, enableSheild : bool):
	$windButton.showButton(enableWind)
	$attackButton.showButton(enableAttack)
	$healButton.showButton(enableHeal)
	$sheildButton.showButton(enableSheild)

#TODO: link above signals to buttons movements
#link up all signals from this node to player
#move hp and tj bar to UI layer and link up
func updateMiniGameActive():
	emit_signal("minigameActiveUpdate",  $healButton/catchMiniGame.healFlying or $windButton/windWatchMiniGame.is_processing_input() or $attackButton/comboMiniGame.is_processing_input())

func windWatchButtonPressed():
	if sheildActive or not actionsActive:
		return
	$windButton/windWatchMiniGame.playGame()
	updateMiniGameActive()
	emit_signal("winding", $windButton/windWatchMiniGame.is_processing_input())
func _on_windWatchMiniGame_wind():
	emit_signal("watchWind", 1)
func _on_windWatchMiniGame_failedWind():
	emit_signal("watchWind", -1)

	
func healButtonPressed():
	if sheildActive or not actionsActive:
		return
	$healButton/catchMiniGame.playGame()
	updateMiniGameActive()
	emit_signal("healing", true)
func _on_catchMiniGame_caughtHeal():
	updateMiniGameActive()
	emit_signal("caughtHeal", 1)
	emit_signal("healing", false)
#	emit_signal("PlayerHit") #update HP bar in parent node
func _on_catchMiniGame_gameEnded():
	updateMiniGameActive()
	emit_signal("healing", false)


func attackButtonPressed():
	if sheildActive or not actionsActive:
		return
	$attackButton/comboMiniGame.playGame()
	updateMiniGameActive()
	emit_signal("attacking", $attackButton/comboMiniGame.is_processing_input())
func _on_comboMiniGame_successfulCombo(damage):
	if abs(Global.getEnemyDisplacementFromPlayer().x) <= 1 and abs(Global.getEnemyDisplacementFromPlayer().y) <= 1:
		get_tree().call_group("enemies", "getHit", damage)
		#do enemy damage anim
	else:
		pass
		#do miss anim

#todo: equipping shield is instant, removing it takes time, but you CAN remove it 
func shieldButtonPressed():
	if sheildActive or not actionsActive:
		return
	sheildActive = true
	$healButton/catchMiniGame.gameEnd()
	$windButton/windWatchMiniGame.gameEnd()
	updateMiniGameActive()
	emit_signal("sheildActivated")
