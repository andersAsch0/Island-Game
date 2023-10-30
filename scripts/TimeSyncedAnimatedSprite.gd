class_name TimeSyncedAnimatedSprite

extends AnimatedSprite


var secondsPerFrame : float = 0.0
var frameCountMultiplier : int = 1
var indexOfLastFrame : int = 0
export var isPlaying : bool = true #do not turn on animatedsprites playing
# Called when the node enters the scene tree for the first time.
func _ready():
	playing = false
	secondsPerFrame = 1.0 / frames.get_animation_speed(animation)
	indexOfLastFrame = frames.get_frame_count(animation) - 1

func play(anim : String = "default", backwards : bool = false) -> void:
	isPlaying = true
	switchAnim(anim)
	# if time is reversed and backwards is false, frame = last frame
	# if timme is reversed and backwards T, frame = first frame #this ones messed up
	# if time is nortmal and backwards F, frame = first
	# if time is normal and backwards T, frame = last
	if Global.currCombatTimeMultiplier > 0 == backwards:
		frame = indexOfLastFrame
	else:
		frame = 0
	
	if backwards: 
		frameCountMultiplier = -1

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
	if isPlaying: count += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int) * frameCountMultiplier
	if count > secondsPerFrame:
		if frame == indexOfLastFrame:
			if frames.get_animation_loop(animation): frame = 0
			else: isPlaying = false
		else:
			frame = frame + 1
		count = 0
	if count < 0:
		if frame == 0:
			if frames.get_animation_loop(animation): 
				frame = indexOfLastFrame
			else:
				isPlaying = false
		else:
			frame = frame - 1
		count = secondsPerFrame

