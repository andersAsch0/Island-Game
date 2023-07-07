extends CollisionShape2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


signal test

func _process(delta):
	emit_signal("test")
