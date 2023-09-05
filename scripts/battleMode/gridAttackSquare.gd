extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "animationFinished")
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	play("notVisible")

func attack(warningTime):
	frames.set_animation_speed("warning", 1.0 / warningTime * 4) # divided by no of frames
	play("warning")
	

func animationFinished():
	if animation == "warning":
		play("attack")
		$HitBox/CollisionShape2D.set_deferred("disabled", false)
	elif animation == "attack":
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
		play("retreat")
