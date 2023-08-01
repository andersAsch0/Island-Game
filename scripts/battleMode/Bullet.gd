extends Area2D


export var speed : int = 50
export var angle : float = 0 #in radians
export var warningAnimationTime = 1 #how long does the warning anim play before the bullet shoots
var warningCount = 0
var velocity = Vector2.DOWN
# depawn timer should be long enough that even if the player uses all their time reverse at once,
# the bullets will not have despawned too early
# maybe this can be adjusted by the player script when the player has little time reversal left, in order to optimize
enum {
	WARNING
	MOVING
}
var currState

func _ready():
	$AnimatedSprite.play("warning")
	currState = WARNING

func _process(delta):
	if currState == WARNING:
		warningCount += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		if warningCount < 0:
			queue_free()
		elif warningCount >= warningAnimationTime:
			currState = MOVING
			$AnimatedSprite.play("default")
	else:
		position += velocity.rotated(angle) * speed * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
func reverseTime():
	pass
func speedUpTime(_multiplier : float = 1): #can pass in number, if no number default is 1 (no change)
	pass
func stopTime():
	pass
func resumeTime():
	pass
	
	

# DESPAWNING STUFF

func getHit(_damage : int): #called when bullet hits player or enemy
	die()
func _on_VisibilityNotifier2D_screen_exited():
	if not $DespawnTimer.paused: #dont call start when it gets deleted
		$DespawnTimer.start() #if it exits the screen, start the timer, ignoring any past enters or exits
func _on_VisibilityNotifier2D_screen_entered():
	if not $DespawnTimer.paused:
		$DespawnTimer.stop() #dont despawn on screen
func _on_DespawnTimer_timeout():
	queue_free()
func die(): #called by enemy when it dies
	$AnimatedSprite.play("die")
	#$HitBox.queue_free() # dont hit player during explosion animation
	set_process(false) #stop moving
	$DeathTimer.start() # give time for explosion to play
func _on_DeathTimer_timeout():
	queue_free()

	

func _on_Bullet_child_exiting_tree(_timer : Timer): # please stop 
	$DespawnTimer.paused = true



