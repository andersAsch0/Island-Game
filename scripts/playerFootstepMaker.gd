extends Node2D

var timer

var tileSetName = "footstepMap"
onready var tileSetStepSound = [$grassFootstep, $waterFootstep, $sandFootstep, $woodFootstep]
var tileSetNode 
#a better way would be to instanciate a new streamplayer each time, and queue free when its done

signal currentStepMaterial(tileID)

func _ready():
	timer = $footstepTimer
	tileSetNode = get_tree().get_root().find_node("footstepMap", true, false)
	if tileSetNode == null: set_process(false)

func _process(_delta):
	if timer.time_left == 0 and owner.velocity != Vector2.ZERO:
		$footstepTimer.start()
		playerSteps()
		
#var currentCell = Vector2.ZERO
var currentTile:int = -1
func playerSteps():
#	currentCell = Vector2((owner.position.x / (tileSetNode.cell_size.x * tileSetNode.scale.x)) as int, (owner.position.y / (tileSetNode.cell_size.y * tileSetNode.scale.y)) as int)
	currentTile = tileSetNode.get_cell((owner.position.x / (tileSetNode.cell_size.x * tileSetNode.scale.x)) as int, (owner.position.y / (tileSetNode.cell_size.y * tileSetNode.scale.y)) as int)
	if currentTile != -1 and currentTile < tileSetStepSound.size():
		playFootStep(tileSetStepSound[currentTile])
		emit_signal("currentStepMaterial", currentTile)

func playFootStep(audioStreamNode):
	if audioStreamNode.playing:
		if audioStreamNode.get_children().size() > 0:
			playFootStep(audioStreamNode.get_child(0)) #recursively go down the tree of children until you find one that isnt playing
		else: audioStreamNode.play()
	else: 
		audioStreamNode.play()
		

func _on_footstepTimer_timeout():
	if owner.velocity > Vector2.ZERO:
		playerSteps()
		$footstepTimer.start()
