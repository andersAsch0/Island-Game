extends AnimatedSprite2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	set_process(false)
# Called when the node enters the scene tree for the first time.
var count = 1.0
var signMultiplier = -1
func _process(delta):
	if abs(count) > 1:
		signMultiplier = signMultiplier * -1
	count += delta * signMultiplier * 3
	self_modulate.b = abs(count)
	self_modulate.g = abs(count)

func playHurtAnimation():
	set_process(true)

func _on_damageCooldownTimer_timeout():
	set_process(false)
	self_modulate.b = 1
	self_modulate.g = 1
	count = 1.0
	
