extends Sprite

var scaleValues = [5.289, 4.844, 4.4, 3.956, 3.511]
func getScaleVector(gridYLocation):
	return Vector2(scaleValues[gridYLocation], scaleValues[gridYLocation])
	
var perspectiveCoordsX = [[196, 179, 162, 144, 125], [1811, 171, 162, 152, 142], [162, 162, 162, 162, 162], [136, 150, 162, 174, 188], [104, 133, 162, 190, 218]]
var perspectiveCoordsY = [58, 45, 44, 78, 105]
func getCoords(gridLocation : Vector2):
	return Vector2(perspectiveCoordsX[gridLocation.y][gridLocation.x], perspectiveCoordsY[gridLocation.y])


var moving = false
var currPlayerTile : Vector2
var prevScale : Vector2
var prevCoords : Vector2
var timeToMove
func _process(delta):
	if moving:
		scale += 1.0 * (getScaleVector(currPlayerTile.y) - prevScale) / timeToMove * delta
		position += 1.0 * (getCoords(currPlayerTile) - prevCoords) / timeToMove * delta
func _on_BattleModePlayer_playerMovedOffense(direction, newTile, timeToMoveThere):
	prevScale = scale
	prevCoords = position
	currPlayerTile = newTile
	timeToMove = timeToMoveThere
	moving = true
func _on_BattleModePlayer_playerFinishedMoving(newTile):
	moving = false
