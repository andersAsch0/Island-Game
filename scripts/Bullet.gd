extends Area2D


export var speed : int = 50
# depawn timer should be long enough that even if the player uses all their time reverse at once,
# the bullets will not have despawned too early
# maybe this can be adjusted by the player script when the player has little time reversal left, in order to optimize

func _process(delta):
	if len(get_overlapping_bodies()) != 0:
		#play animation
		get_tree().call_group("player", "getHit") 
		position.x = -1000 #this is dumb but I have more important things to do so this will do for now
		position.y = -1000
		queue_free()
		
	position.y += speed * delta
	

func _on_VisibilityNotifier2D_screen_exited():
	if is_inside_tree(): #dont call start when it gets deleted
		$DespawnTimer.start() #if it exits the screen, start the timer, ignoring any past enters or exits
func _on_VisibilityNotifier2D_screen_entered():
	if is_inside_tree():
		$DespawnTimer.stop() #dont despawn on screen
func _on_DespawnTimer_timeout():
	queue_free()

func reverseTime():
	speed = speed * -1

