extends Node2D


var catcherStartPos = Vector2(147, 123)
var healStartPos = Vector2(-20, 120)
var healFlying = false
var rng = RandomNumberGenerator.new()
signal caughtHeal
signal gameEnded

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = hash("weeeee")

func playGame():
	if not healFlying:
		set_process(true)
		$catcher.play("default")
		$AnimatedSprite.frame = 0
		if not $catcher.visible:
			$catcher.position = catcherStartPos
			$catcher.visible = true
		$Heart.position = healStartPos
		healVelocity = Vector2.UP.rotated(rng.randf_range(0.1, PI/2 - 0.8)) * 200
		healFlying = true

var healVelocity = Vector2.ZERO
var grav = Vector2.DOWN * 200
var input : float = 0
func _process(delta):
	if healFlying:
		$Heart.position += healVelocity * delta
		healVelocity += grav * delta
		if $Heart.position.y > 214:
			healFlying = false
			gameEnd()
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	$catcher.position.x += input * delta * 100


func _on_HurtBox_hurtBoxHit(_damage):
	caughtHeal()
func caughtHeal():
	$catcher.play("caughtHeal")
	$Heart.position = healStartPos
	healFlying = false
	emit_signal("caughtHeal")

func gameEnd():
	set_process(false)
	$catcher.visible = false
	emit_signal("gameEnded")


func _on_catcher_animation_finished():
	if $catcher.animation == "caughtHeal":
		gameEnd()
