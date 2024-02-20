extends Area2D


@export var speed : int = 120
@export var angle : float = 0 #in radians
@export var warningAnimationTime = 1 #how long does the warning anim play before the bullet shoots (set by musicAttackController)
@export var shakeCamera : bool = false
var battleModeCameraPath = "/root/BattleMode/offenseModeCamera"
var cameraNode = null
var warningCount = 0
var velocity = Vector2.DOWN
# depawn timer should be long enough that even if the player uses all their time reverse at once,
# the bullets will not have despawned too early
# maybe this can be adjusted by the player script when the player has little time reversal left, in order to optimize
enum {
	WARNING,
	MOVING,
	DYING
}
var currState


func init(warningTime): #this is called before ready
	warningAnimationTime = max(warningTime, 0)
	$WarningTimer.wait_time = warningAnimationTime
	return self
func _ready():
	currState = WARNING
	$TimeSyncedAnimatedSprite.play("warning")
	scale = Vector2(0.05,0.05)
	$TimeSyncedAnimatedSprite.self_modulate.a = 0
	cameraNode = get_node_or_null(battleModeCameraPath)
	if not cameraNode:
		shakeCamera = false
#	if not get_tree().root.has_node(battleModeCameraPath):
#		shakeCamera = false
#	else:
#		cameraNode = get_node(battleModeCameraPath)


func _process(delta):
	if currState == WARNING:
		#warningCount += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		scale.x += 2.0 / warningAnimationTime * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		scale.y += 2.0 / warningAnimationTime * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		$TimeSyncedAnimatedSprite.self_modulate.a += 1.0 / warningAnimationTime * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)
		rotate(2*PI / warningAnimationTime * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int))
	else: 
		position += velocity.rotated(angle) * speed * delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int)


##time reversed to before bullet was spawned
func _on_warning_timer_timer_start_undone():
	queue_free()
##bullet entering normal state
func _on_warning_timer_timeout():
	scale.x = 1
	scale.y = 1
	$TimeSyncedAnimatedSprite.play("default")
	rotation = 0
	$bulletTrail.visible = true
	currState = MOVING
	if shakeCamera: cameraNode.cameraPulse(0.3)

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
##despawning after leaving the screen
func _on_DespawnTimer_timeout():
	queue_free()

##called by enemy when it dies, bullets should go away
func die(): 
	$TimeSyncedAnimatedSprite.play("die")
	$bulletTrail.visible = false
	#$HitBox.queue_free() # dont hit player during explosion animation
	set_process(false)
	$DeathTimer.start() # give time for explosion to play
	syncGPUParticlesWithGlobalTime()
	$GPUParticles2D.emitting = true


func _on_DeathTimer_timeout():
	queue_free()
	
signal despawned
func _on_Bullet_child_exiting_tree(_node : Node): # please stop 
	$DespawnTimer.paused = true
	emit_signal("despawned")

func syncGPUParticlesWithGlobalTime():
	$GPUParticles2D.process_material.initial_velocity_max = Global.currCombatTimeMultiplier * speed
	$GPUParticles2D.process_material.initial_velocity_min = Global.currCombatTimeMultiplier * speed
	$GPUParticles2D.lifetime = $GPUParticles2D.lifetime * abs(Global.currCombatTimeMultiplier)
	


