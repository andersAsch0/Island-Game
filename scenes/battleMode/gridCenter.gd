extends CenterContainer

# Called when the node enters the scene tree for the first time.
onready var grid = $bigGrid3
var animTime = 0.8 # should be the same as the battlemode enemys angle change state
var isPlayerOffensePhase = true
var scale2D = 1.0
var scale3D = 0.33
var YScaleChange : float = scale2D - scale3D
var coords2d = []
var coords3d = []

func _ready():
	coords2d = generate2dCoords($bigGrid3/frame0Corner.position, $bigGrid3/frame0Corner3.position)
	coords3d = generate3dCoords($bigGrid3/frame8Corner.position, $bigGrid3/frame8Corner2.position, $bigGrid3/frame8Corner3.position, $bigGrid3/frame8Corner4.position,
	$bigGrid3/frame8LeftSide2.position, $bigGrid3/frame8LeftSide3.position, $bigGrid3/frame8LeftSide4.position, $bigGrid3/frame8RightSide2.position, $bigGrid3/frame8RightSide3.position, $bigGrid3/frame8RightSide4.position)
	updateGlobal(coords3d)
	

func _process(delta):
	if isPlayerOffensePhase: # going from offense (3d) to defense (2d) (stretch)
		rect_scale.y += (YScaleChange / animTime) * delta
#		grid.position -= (offsetFrom2DTo3D[Global.playerGridLocation.x][Global.playerGridLocation.y] / animTime) * delta
	else: # going from 2d to 3d (squash)
		rect_scale.y -= (YScaleChange / animTime) * delta
#		grid.position += (offsetFrom2DTo3D[Global.playerGridLocation.x][Global.playerGridLocation.y] / animTime) * delta

func _on_BattleMode_enemyAttackPhaseStarting(): #end change to 2d
	set_process(false)
	rect_scale.y = scale2D
func startAngleChangeTo2D(): #called by the camera which sets its position, so it doesnt start moving until it has the correct position
	isPlayerOffensePhase = true # (on anglechange phase starting)
	set_process(true)
	grid.play("default", true)

func _on_BattleMode_enemyAwayPhaseStarting(): # end angle change to 3d
	set_process(false)
	rect_scale.y = scale3D
func _on_BattleMode_enemyAbscondPhaseStarting(): #change to 3d
	isPlayerOffensePhase = false
	set_process(true)
	grid.play("default", false)

func generate2dCoords(topLeft: Vector2, bottomRight: Vector2): #return arrays
	var array = []
	var distBetweenLocations : float = (bottomRight.x - topLeft.x) / 4
	for y in range(5): #goes 0, 1, 2, 3, 4
		array.append([])
		for x in range(5):
			array[y].append(Vector2(x * distBetweenLocations + topLeft.x, y * distBetweenLocations + topLeft.y))
	return array
			
func generate3dCoords(topLeft: Vector2, topRight: Vector2, bottomRight: Vector2, bottomLeft: Vector2, square01 : Vector2, square02: Vector2, square03: Vector2, square41: Vector2, square42: Vector2, square43: Vector2):
	var array = []
	var distBetweenLocations : float
	var leftColumn = [topLeft, square01, square02, square03, bottomLeft]
	var rightColumn = [topRight, square41, square42, square43, bottomRight]
	for y in range(5):
			distBetweenLocations = (rightColumn[y].x - leftColumn[y].x) / 4
			array.append([])
			for x in range(5):
				array[y].append(Vector2(leftColumn[y].x + distBetweenLocations * x, leftColumn[y].y))
	return array
func updateGlobal(full3DCoordsRelativeToGridCenter):
	Global.gridCoords = []
	for y in range(5):
		Global.gridCoords.append([])
		for x in range(5):
			Global.gridCoords[y].append(Vector2(full3DCoordsRelativeToGridCenter[y][x].x * rect_scale.x + rect_position.x, full3DCoordsRelativeToGridCenter[y][x].y * rect_scale.y + rect_position.y))
	print(Global.gridCoords)
		
