extends Sprite

# on defense mode starting, do zoomy thing

#func _process(delta):
#	return
#	if moving:
#		scale += 1.0 * (getScaleVector(currPlayerTile.y) - prevScale) / timeToMove * delta
#		position += 1.0 * (getCoords(currPlayerTile) - prevCoords) / timeToMove * delta
#func _on_BattleModePlayer_playerMovedOffense(direction, newTile, timeToMoveThere):
#	prevScale = scale
#	prevCoords = position
#	currPlayerTile = newTile
#	timeToMove = timeToMoveThere
#	moving = true
#func _on_BattleModePlayer_playerFinishedMoving(newTile):
#	moving = false
