extends Sprite



func _on_BattleMode_enemyAbscondPhaseStarting(_duration):
	visible = false

func _on_BattleMode_enemyAngleChangePhaseStarting(_duration):
	visible = false


func _on_BattleMode_enemyApproachPhaseStarting(_duration):
	visible = false


func _on_BattleMode_enemyAttackPhaseStarting(_duration):
	visible = true


func _on_BattleMode_enemyAwayPhaseStarting(_duration):
	visible = false
