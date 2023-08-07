extends Node2D


enum { RIGHT, LEFT, UP, DOWN }


func _on_BattleModePlayer_playerMovedOffense(direction):
	if direction == UP or direction == DOWN:
		$downArrow.updateSelf(DOWN)
		$upArrow.updateSelf(UP)
	else:
		$rightArrow.updateSelf(RIGHT)
		$leftArrow.updateSelf(LEFT)
