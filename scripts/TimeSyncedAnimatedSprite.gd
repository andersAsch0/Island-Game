class_name TimeSyncedAnimatedSprite

extends AnimatedSprite


var secondsPerFrame : float = 0.0
var frameCountMultiplier : int = 1
var indexOfLastFrame : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	playing = false
	secondsPerFrame = 1.0 / frames.get_animation_speed(animation)
	indexOfLastFrame = frames.get_frame_count(animation) - 1

func play(anim : String = "default", backwards : bool = false) -> void:
	switchAnim(anim)
	frame = 0
	if backwards: frameCountMultiplier = -1

func switchAnim(anim : String):
	if not frames.has_animation(anim): 
		print("ERROR: animatedSprite has no animation ", anim)
		return
	animation = anim
	frameCountMultiplier = 1
	secondsPerFrame = 1.0 / frames.get_animation_speed(animation)
	indexOfLastFrame = frames.get_frame_count(animation) - 1

var count : float = 0
func _process(delta):
	count += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int) #* frameCountMultiplier
	if count > secondsPerFrame:
		if frame == indexOfLastFrame and frames.get_animation_loop(animation):
			frame = 0
		else:
			frame = frame + 1
		count = 0
	if count < 0:
		if frame == 0 and frames.get_animation_loop(animation): 
			frame = indexOfLastFrame
		else:
			frame = frame - 1
		count = secondsPerFrame
