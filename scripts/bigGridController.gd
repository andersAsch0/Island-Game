extends Node2D


var animTime2Dto3D = 0.8 # should be the same as the battlemode enemys angle change state
var animTime3Dto2D = 0.8 # should be the same as the battlemode enemys angle change state
var isPlayerOffensePhase = true
var scale2D = 1.0
var scale3D = 0.33
var YScaleChange : float = scale2D - scale3D
var coords2d = []
var coords3d = []
var baselinePosition3D = position

func _ready():
	coords2d = generate2dCoords($bigGrid/frame0Corner.position, $bigGrid/frame0Corner3.position)
	coords3d = generate3dCoords($bigGrid/frame8Corner.position, $bigGrid/frame8Corner2.position, $bigGrid/frame8Corner3.position, $bigGrid/frame8Corner4.position,
	$bigGrid/frame8LeftSide2.position, $bigGrid/frame8LeftSide3.position, $bigGrid/frame8LeftSide4.position, $bigGrid/frame8RightSide2.position, $bigGrid/frame8RightSide3.position, $bigGrid/frame8RightSide4.position)
	updateGlobal(coords3d)
	
var timeBetweenFrames = 0.0
func _process(delta):
	if $bigGrid.frameCountMultiplier > 0: # going from offense (3d) to defense (2d) (stretch)
		position += (offsetFrom2DTo3D(Global.playerGridLocation.x,Global.playerGridLocation.y) / animTime3Dto2D) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	else: # going from 2d to 3d (squash)
		position -= (offsetFrom2DTo3D(Global.playerGridLocation.x, Global.playerGridLocation.y) / animTime2Dto3D) * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)

func _on_BattleMode_enemyApproachPhaseStarting(_duration):
	set_process(false)
func _on_BattleMode_enemyAngleChangePhaseStarting(duration):
	animTime3Dto2D = duration
	$bigGrid.set_anim_duration(duration, "default")
	startAngleChangeTo2D()
func startAngleChangeTo2D(): #called by the camera which sets its position, so it doesnt start moving until it has the correct position
	isPlayerOffensePhase = true # (on anglechange phase starting)
	set_process(true)
	$bigGrid.play("default", false)

func _on_BattleMode_enemyAttackPhaseStarting(_duration): #end change to 2d
	set_process(false)
#	position = baselinePosition3D
func _on_BattleMode_enemyAbscondPhaseStarting(duration): #change to 3d
	animTime2Dto3D = duration
	$bigGrid.set_anim_duration(duration, "default")
	isPlayerOffensePhase = false
	set_process(true)
	$bigGrid.play("default", true)
func _on_BattleMode_enemyAwayPhaseStarting(_duration): # end angle change to 3d
	set_process(false)
	position = Vector2.ZERO

func generate2dCoords(topLeft: Vector2, bottomRight: Vector2): #return arrays
	var array = []
	var distBetweenLocations : float = (bottomRight.x - topLeft.x) / 4
	for y in range(5): #goes 0, 1, 2, 3, 4
		array.append([])
		for x in range(5):
			array[y].append(Vector2(x * distBetweenLocations + topLeft.x, y * distBetweenLocations + topLeft.y))
	return array
			
func generate3dCoords(topLeft: Vector2, topRight: Vector2, bottomRight: Vector2, bottomLeft: Vector2, square01 : Vector2, square02: Vector2, square03: Vector2, square41: Vector2, square42: Vector2, square43: Vector2):
	#ordered in the reverse way of normal coords, each row is y and each col is x, so that to get a coord you have to use [y][x]
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
			Global.gridCoords[y].append(Vector2(full3DCoordsRelativeToGridCenter[y][x].x + position.x, full3DCoordsRelativeToGridCenter[y][x].y + position.y))
		
func offsetFrom2DTo3D(gridLocationX, gridLocationY):
	#3d - 2d
	return Vector2(coords3d[gridLocationY][gridLocationX].x - coords2d[gridLocationY][gridLocationX].x, coords3d[gridLocationY][gridLocationX].y - coords2d[gridLocationY][gridLocationX].y)
	


