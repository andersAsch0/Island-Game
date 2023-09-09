extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lengthOfWarningSeconds = 0.5
var bulletPackedScene = null # passed in by controller
var laserFireTimeSeconds = 2
var bulletFireIntervalSeconds = 0.3
var latestBulletSpawned

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	var nodes = get_children()
	for sprite in nodes:
		sprite.frames.set_animation_speed("default", 1.0 * sprite.frames.get_frame_count("default") / lengthOfWarningSeconds)
		sprite.play("default")
		sprite.visible = true

func _on_AnimatedSprite_animation_finished():
	queue_free()
	set_process(true)

var intervalCount = 0.0
func _process(delta):
	laserFireTimeSeconds -= delta
	intervalCount += delta
	if laserFireTimeSeconds < 0:
		latestBulletSpawned.connect("depsawned", self, "despawn")
	elif bulletPackedScene != null and intervalCount > bulletFireIntervalSeconds:
		latestBulletSpawned = bulletPackedScene.instance()
		add_child(latestBulletSpawned)
		intervalCount = 0

func despawn():
	queue_free()
