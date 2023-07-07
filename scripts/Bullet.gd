extends Area2D


export var speed : int = 50


func _process(delta):
	if len(get_overlapping_bodies()) != 0:
		#play animation
		queue_free()
		
	position.y += speed * delta
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free() #delete self when it leaves the screen
