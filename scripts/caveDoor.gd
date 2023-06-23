extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(String, FILE, "*.tscn") var ScenePath

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_accept"): #enter key (player has to press enter to go thru
		if get_overlapping_bodies().size() > 0: #get num of things overlapping (looking for player)
				next_level()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func next_level():
	var PTS = get_tree().change_scene(ScenePath) #takes packedScene
