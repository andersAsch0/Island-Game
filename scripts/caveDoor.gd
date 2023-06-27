extends Area2D


export(String, FILE, "*.tscn") var ScenePath #prevents cyclical reference error. RAAH

onready var Global = get_node("/root/Global") # get reference(?) to the global script #idk what onready does



			
func _process(_delta):
	if get_overlapping_bodies().size() > 0: #get num of things overlapping (looking for player)
			next_level()


func next_level():
	var _PTS = get_tree().change_scene(ScenePath) # change_scene takes path, change_scene_to takes PackedScene
	Global.door_name = name #pass the door name to the global script so other scripts can access it and know what to do (where to spawn player)
