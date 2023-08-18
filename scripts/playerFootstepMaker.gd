extends Node2D

var timer
var grassTileSet
var sandTileSet
var woodTileSet1
var woodTileSet2

func _ready():
	timer = $footstepTimer
	grassTileSet = get_node("../../../grass")
	sandTileSet = get_node("../../../sandAndWaterEdges")
	woodTileSet1 = get_node("../../../wood top")
	woodTileSet2 = get_node("../../../wood bottom")
	if grassTileSet == null or sandTileSet == null or woodTileSet1 == null or woodTileSet2 == null:
		print("ERROR: player footstep script cant find tilesets")
		set_process(false) #disable this whole thing if cant find tilesets

func _process(delta):
	if timer.time_left == 0 and owner.velocity != Vector2.ZERO:
		$footstepTimer.start()
		playerSteps()
		
var currentCell = Vector2.ZERO
func playerSteps():
	currentCell = Vector2((owner.position.x / (sandTileSet.cell_size.x * sandTileSet.scale.x)) as int, (owner.position.y / (sandTileSet.cell_size.y * sandTileSet.scale.y)) as int)
	#this assumes that all tile sets will have the same cell size and scale
	if woodTileSet1.get_cell(currentCell.x, currentCell.y) != -1 or woodTileSet2.get_cell(currentCell.x, currentCell.y) != -1:
		$woodFootstep.play()
	elif sandTileSet.get_cell(currentCell.x, currentCell.y) != -1:
		$sandFootstep.play()
	elif grassTileSet.get_cell(currentCell.x, currentCell.y) != -1:
		$grassFootstep.play()
func _on_footstepTimer_timeout():
	if owner.velocity > Vector2.ZERO:
		playerSteps()
		$footstepTimer.start()
