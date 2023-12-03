extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lengthOfWarningSeconds = 0.5
var bulletPackedScene = null 
var bulletFireIntervalSeconds = 0.1
var latestBulletSpawned
var numberOfBullets

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	var nodes = get_children()
	for sprite in nodes:
		sprite.frames.set_animation_speed("default", 1.0 * sprite.frames.get_frame_count("default") / lengthOfWarningSeconds)
		sprite.play("default")
		sprite.visible = true
		
func _init(bulletPacked : PackedScene, bulletNum : int, bulletInterval : float, warningLength : float):
	bulletPackedScene = bulletPacked
	numberOfBullets = bulletNum
	bulletCount = bulletNum
	bulletFireIntervalSeconds = bulletInterval
	lengthOfWarningSeconds = warningLength
	return self

func _on_AnimatedSprite_animation_finished():
	if bulletPackedScene != null: set_process(true)

var intervalCount = 0.0
var bulletCount
func _process(delta):
	intervalCount += delta
	if bulletCount <= 0:
		latestBulletSpawned.connect("despawned", self, "despawn") #??
		set_process(false)
	elif intervalCount > bulletFireIntervalSeconds:
		latestBulletSpawned = bulletPackedScene.instance()
		add_child(latestBulletSpawned)
		bulletCount -= 1

func despawn():
	queue_free()
