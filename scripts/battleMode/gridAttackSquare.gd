extends AnimatedSprite

func _ready():
	connect("animation_finished", self, "animationFinished")
	$HitBox/CollisionShape2D.set_deferred("disabled", true)

func attack():
	play("warning")

func animationFinished():
	if animation == "warning":
		play("attack")
		$HitBox/CollisionShape2D.set_deferred("disabled", false)
	elif animation == "attack":
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
		play("notVisible")
