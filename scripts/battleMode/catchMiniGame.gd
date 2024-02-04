extends Node2D


var catcherStartPos = Vector2(147, 123)
var healStartPos = Vector2(-20, 120)
var healFlying = false
var rng = RandomNumberGenerator.new()
signal caughtHeal
signal gameEnded

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	rng.seed = hash("weeeee")
	catcherStartPos = $catcher.position
	healStartPos = $CanvasLayer/Heart.position

func playGame():
	if not healFlying:
		set_process(true)
		$catcher.play("default")
		$CanvasLayer/AnimatedSprite2D.frame = 0
#		if not $catcher.visible:
#			$catcher.position = catcherStartPos
#			$catcher.visible = true
		$CanvasLayer/Heart.position = healStartPos
		healVelocity = Vector2.UP.rotated(rng.randf_range(0.1, PI/2 - 0.75)) * 250
		healFlying = true

var healVelocity = Vector2.ZERO
var grav = Vector2.DOWN * 200
var input : float = 0
func _process(delta):
	if healFlying:
		$CanvasLayer/Heart.position += healVelocity * delta
		healVelocity += grav * delta
		if $CanvasLayer/Heart.position.y > 214:
			set_process(false)
			healFlying = false
			$CanvasLayer/Heart.position = healStartPos
			playGame()
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	$catcher.position.x += input * delta * 130


func _on_HurtBox_hurtBoxHit(_damage):
	HealCaught()
func HealCaught():
	$catcher.play("caughtHeal")
	$CanvasLayer/Heart.position = healStartPos
	healFlying = false
	$healSFX.play(0.0)
	emit_signal("caughtHeal")
	playGame()
	

func gameEnd():
	set_process(false)
	healFlying = false
	$catcher.position = catcherStartPos
	emit_signal("gameEnded")
	$CanvasLayer/Heart.position = healStartPos


#func _on_catcher_animation_finished():
#	if $catcher.animation == "caughtHeal":
#		gameEnd()
