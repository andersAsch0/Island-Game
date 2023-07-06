extends KinematicBody2D

export var finalScale = 2
export var approachTime = 2
var approaching = false
var origScale
signal startFight

func _ready():
	$ApproachTimer.wait_time = approachTime
	$ApproachTimer.start()
	$AnimatedSprite.play("moving")

func approach(): #when called (by outside battleMode script), enemy does whatever it needs to do at beginning of fight
	approaching = true #usually, that will be to slowly approach
	origScale = scale.x

func _physics_process(delta):
	if approaching: #increase scale (grow bigger each frame)
		scale.x += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta 
		scale.y += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta

func _on_ApproachTimer_timeout(): #when timer finishes, sprite is proper size
	approaching = false #stop growing
	$AnimatedSprite.play("idle")
	emit_signal("startFight")
	introduction()

func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting
