extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _input(event):
	if event.is_action_pressed("windWatch"):
		visible = true
	elif event.is_action_released("windWatch"):
		visible = false

func _on_sixteenthDayTimer_timeout():
	frame += 1
	if frame == 16:
		frame = 0
