extends Node2D


var catcherStartPos = Vector2(147, 123)
var healStartPos = Vector2(-20, 120)
var healFlying = false
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = hash("weeeee")

func playGame():
	if not healFlying:
		set_process(true)
		$AnimatedSprite.play("default")
		$catcher.position = catcherStartPos
		$catcher.visible = true
		$Heart.position = healStartPos
		healVelocity = Vector2.UP.rotated(rng.randf_range(0.1, PI/2 - 0.8)) * 200
		healFlying = true

var healVelocity = Vector2.ZERO
var grav = Vector2.DOWN * 200
func _process(delta):
	if healFlying:
		$Heart.position += healVelocity * delta
		healVelocity += grav * delta

func caughtHeal():
	pass

func gameEnd():
	set_process(false)
	$catcher.visible = false
