extends AnimatedSprite

var animTime = 0.8 # should be the same as the battlemode enemys angle change state
var isPlayerOffensePhase = true
var scale2D = 1.0
var scale3D = 0.33
var YScaleChange : float = scale2D - scale3D
var coords2d = []
var coords3d = []
var baselinePosition3D = position

func _ready():
	coords2d = generate2dCoords($frame0Corner.position, $frame0Corner3.position)
	coords3d = generate3dCoords($frame8Corner.position, $frame8Corner2.position, $frame8Corner3.position, $frame8Corner4.position,
	$frame8LeftSide2.position, $frame8LeftSide3.position, $frame8LeftSide4.position, $frame8RightSide2.position, $frame8RightSide3.position, $frame8RightSide4.position)
	updateGlobal(coords3d)
	
var timeBetweenFrames = 0.0
func _process(delta):
	timeBetweenFrames += delta

func _on_bigGrid3_frame_changed():
	if isPlayerOffensePhase: # going from offense (3d) to defense (2d) (stretch)
		position += (offsetFrom2DTo3D(Global.playerGridLocation.x,Global.playerGridLocation.y) / animTime) * timeBetweenFrames * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	else: # going from 2d to 3d (squash)
		position -= (offsetFrom2DTo3D(Global.playerGridLocation.x, Global.playerGridLocation.y) / animTime) * timeBetweenFrames * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
	timeBetweenFrames = 0

func _on_BattleMode_enemyAttackPhaseStarting(): #end change to 2d
	set_process(false)
#	position = baselinePosition3D
	
func startAngleChangeTo2D(): #called by the camera which sets its position, so it doesnt start moving until it has the correct position
	isPlayerOffensePhase = true # (on anglechange phase starting)
	set_process(true)
	play("default", false)

func _on_BattleMode_enemyAwayPhaseStarting(): # end angle change to 3d
	set_process(false)
func _on_BattleMode_enemyAbscondPhaseStarting(): #change to 3d
	isPlayerOffensePhase = false
	set_process(true)
	play("default", true)

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
			Global.gridCoords[y].append(Vector2(full3DCoordsRelativeToGridCenter[y][x].x + position.x, full3DCoordsRelativeToGridCenter[y][x].y + position.y))
		
func offsetFrom2DTo3D(gridLocationX, gridLocationY):
	#3d - 2d
	return Vector2(coords3d[gridLocationY][gridLocationX].x - coords2d[gridLocationY][gridLocationX].x, coords3d[gridLocationY][gridLocationX].y - coords2d[gridLocationY][gridLocationX].y)
	

