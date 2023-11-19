extends Node2D


enum { RIGHT, LEFT, UP, DOWN }

func _ready():
	on_enemyMoved() #update once at beginning

func _on_BattleModePlayer_playerMovedOffense(_direction, _newTile, _timeToMove):
	on_enemyMoved()

func on_enemyMoved():
	$downArrow.updateSelf(DOWN)
	$upArrow.updateSelf(UP)
	$rightArrow.updateSelf(RIGHT)
	$leftArrow.updateSelf(LEFT)



func _on_BattleMode_enemyAbscondPhaseStarting(_duration):
	visible = false


func _on_BattleMode_enemyAngleChangePhaseStarting(_duration):
	visible = false

func _on_BattleMode_enemyApproachPhaseStarting(_duration):
	visible = false

func _on_BattleMode_enemyAttackPhaseStarting(_duration):
	visible = false

func _on_BattleMode_enemyAwayPhaseStarting(_duration):
	visible = true
