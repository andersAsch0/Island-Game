extends Area2D



func _input(event):
	if event.is_action_pressed("ui_accept") and len(get_overlapping_bodies()) != 0: #only body that npc can collide w is player
		use_dialouge()

func use_dialouge():
	var dialouge = get_parent().get_node("Dialouge")
	if dialouge: #if npc has dialogue
		dialouge.start()
