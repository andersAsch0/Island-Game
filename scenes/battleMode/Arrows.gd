extends Node2D


enum { RIGHT, LEFT, UP, DOWN }

func _ready():
	on_enemyMoved() #update once at beginning

func _on_BattleModePlayer_playerMovedOffense(direction):
	on_enemyMoved()

func on_enemyMoved():
	$downArrow.updateSelf(DOWN)
	$upArrow.updateSelf(UP)
	$rightArrow.updateSelf(RIGHT)
	$leftArrow.updateSelf(LEFT)
