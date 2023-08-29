extends CenterContainer

# Called when the node enters the scene tree for the first time.
onready var grid = $bigGrid3
var animTime = 0.8 # should be the same as the battlemode enemys angle change state
var isPlayerOffensePhase = true
var offsetFrom2DTo3D = [
[Vector2(-82, 24), Vector2(-39, 24), Vector2(0, 24), Vector2(39, 24), Vector2(82, 24)],
[Vector2(-71, 61), Vector2(-32, 61), Vector2(0, 61), Vector2(32, 61), Vector2(71, 61)], 
[Vector2(-56, 85), Vector2(-26, 85), Vector2(0, 85), Vector2(26, 85), Vector2(56, 85)],
[Vector2(-38, 79), Vector2(-19, 79), Vector2(0, 79), Vector2(19, 79), Vector2(38, 79)],
[Vector2(-13, 46), Vector2(-7, 46), Vector2(0, 46), Vector2(7, 46), Vector2(13, 46)]]
var YScaleChange : float = 1.0 - 0.33

func _process(delta):
	if isPlayerOffensePhase: # going from offense (3d) to defense (2d) (stretch)
		rect_scale.y += (YScaleChange / animTime) * delta
		grid.position -= (offsetFrom2DTo3D[Global.playerGridLocation.x][Global.playerGridLocation.y] / animTime) * delta
	else: # going from 2d to 3d (squash)
		rect_scale.y -= (YScaleChange / animTime) * delta
		grid.position += (offsetFrom2DTo3D[Global.playerGridLocation.x][Global.playerGridLocation.y] / animTime) * delta

func _on_BattleMode_enemyAttackPhaseStarting():
	set_process(false)
func startAngleChangeTo2D(): #called by the camera which sets its position, so it doesnt start moving until it has the correct position
	isPlayerOffensePhase = true
	set_process(true)
	grid.play("default", true)

func _on_BattleMode_enemyAwayPhaseStarting(): # end angle change
	var gridscale = grid.scale.y
	set_process(false)
func _on_BattleMode_enemyAbscondPhaseStarting():
	isPlayerOffensePhase = false
	set_process(true)
	grid.play("default", false)
