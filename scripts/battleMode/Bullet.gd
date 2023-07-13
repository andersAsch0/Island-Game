extends Area2D


export var speed : int = 50
export var angle : float = 0 #in radians
var velocity = Vector2.DOWN
var timeMultiplier = 1
var timeMultiplierNotZero = 1 # storage for resuming time
# depawn timer should be long enough that even if the player uses all their time reverse at once,
# the bullets will not have despawned too early
# maybe this can be adjusted by the player script when the player has little time reversal left, in order to optimize

func _process(delta):
	position += velocity.rotated(angle) * speed * delta * timeMultiplier
func reverseTime():
	timeMultiplier *= -1
func speedUpTime(multiplier : int = 2): #can pass in number, if no number default is 2 (time is twice as fast)
	timeMultiplier = multiplier * sign(timeMultiplier)
func stopTime():
	timeMultiplierNotZero = timeMultiplier
	timeMultiplier = 0
func resumeTime():
	timeMultiplier = timeMultiplierNotZero
	
	

# DESPAWNING STUFF

func _on_VisibilityNotifier2D_screen_exited():
	if not $DespawnTimer.paused: #dont call start when it gets deleted
		$DespawnTimer.start() #if it exits the screen, start the timer, ignoring any past enters or exits
func _on_VisibilityNotifier2D_screen_entered():
	if not $DespawnTimer.paused:
		$DespawnTimer.stop() #dont despawn on screen
func _on_DespawnTimer_timeout():
	queue_free()
func getHit(_damage : int):
	queue_free()

func _on_Bullet_child_exiting_tree(_timer : Timer): # please stop 
	$DespawnTimer.paused = true
