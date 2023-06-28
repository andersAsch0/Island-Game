extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.door_name: #if player has entered world through the dave door (door_name isnt null)
		#works because this script only runs on World scene when it is loaded (not the cave scene)
		#and we only have to spawn at the starting location once, before the null door_name is overwritten
		#if there were multiple doors to the world scene then we would have to actually check the name
		var door_node = find_node(Global.door_name) #get the door in question
		if door_node:
			# this is where we could add transitions
			# also set camera limits??
			$YSort/Player.position.x = 216
			$YSort/Player.position.y = 38
			

