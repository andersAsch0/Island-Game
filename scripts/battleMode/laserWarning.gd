extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lengthOfWarningSeconds = 0.5
var bulletPackedScene = null 
var bulletFireIntervalSeconds = 0.1
var latestBulletSpawned = null
var numberOfBullets = 1
var showWarningLineAnim : bool = false
#a bullet must have:
#"despawned" signal
#ADD warning length


# Called when the node enters the scene tree for the first time.
func _ready():
	if bulletPackedScene == null: 
		set_process(false)
		despawn()
	intervalCount = bulletFireIntervalSeconds #so bullet spawns right away, and warnings are synced
	if not showWarningLineAnim: return
	var nodes = get_children()
	for sprite in nodes:
		sprite.frames.set_animation_speed("default", 1.0 * sprite.frames.get_frame_count("default") / lengthOfWarningSeconds)
		sprite.play("default")
		sprite.visible = true
		
func init(bulletPacked : PackedScene, bulletNum : int, bulletInterval : float, warningLength : float, showWarningLine : bool = false):
	bulletPackedScene = bulletPacked
	numberOfBullets = max(0, bulletNum) 
	bulletFireIntervalSeconds = max(0, bulletInterval)
	lengthOfWarningSeconds = max(0, warningLength)
	showWarningLineAnim = showWarningLine
	return self

var intervalCount : float = 0.0
onready var bulletCount = numberOfBullets
func _process(delta):
	intervalCount += delta
	if bulletCount <= 0:
		if latestBulletSpawned != null : latestBulletSpawned.connect("despawned", self, "despawn") #despawn when last bullet is gone
		else: despawn() #if there are no bullets spawned
		set_process(false)
	elif intervalCount >= bulletFireIntervalSeconds:
		latestBulletSpawned = bulletPackedScene.instance().init(lengthOfWarningSeconds)
		add_child(latestBulletSpawned)
		bulletCount -= 1
		intervalCount = 0

func despawn():
	queue_free()
