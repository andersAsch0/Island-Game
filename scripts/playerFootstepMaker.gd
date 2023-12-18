extends Node2D

var timer

var tileSetNames = ["wood top",  "wood bottom", "sandAndWaterEdges", "grass"]
onready var tileSetStepSound = [$woodFootstep, $woodFootstep, $sandFootstep, $grassFootstep]
var tileSetNodes = [] #index line up with above, in order of priority, contains null if it doesnt exist in the current scene

func _ready():
	timer = $footstepTimer
	for tileSet in tileSetNames:
		tileSetNodes.append(get_node_or_null("../../../"+tileSet))

func _process(_delta):
	if timer.time_left == 0 and owner.velocity != Vector2.ZERO:
		$footstepTimer.start()
		playerSteps()
		
var currentCell = Vector2.ZERO
func playerSteps():
	for i in tileSetNodes.size():
		if tileSetNodes[i] != null:
			currentCell = Vector2((owner.position.x / (tileSetNodes[i].cell_size.x * tileSetNodes[i].scale.x)) as int, (owner.position.y / (tileSetNodes[i].cell_size.y * tileSetNodes[i].scale.y)) as int)
			if tileSetNodes[i].get_cell(currentCell.x, currentCell.y) != -1:
				tileSetStepSound[i].play()
				return
func _on_footstepTimer_timeout():
	if owner.velocity > Vector2.ZERO:
		playerSteps()
		$footstepTimer.start()
