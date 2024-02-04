class_name TimeSyncedAnimatedSprite

extends AnimatedSprite2D


var secondsPerFrame : float = 0.0
var frameCountMultiplier : int = 1
var indexOfLastFrame : int = 0
@export var isPlaying : bool = true #do not turn on animatedsprites playing
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.timeFlowHasChanged.connect(_on_Global_Time_Flow_Has_Changed)
	secondsPerFrame = 1.0 / sprite_frames.get_animation_speed(animation)
	indexOfLastFrame = sprite_frames.get_frame_count(animation) - 1

func _on_Global_Time_Flow_Has_Changed(newFlow : float, _duration, _start):
	#if new flow is 0 and anim playing, pause
	#if new flow is not 0 and anim paused, unpause (dont use pause otherwise else this might start something it shouldnt)
	#else set custom speed to newFlow if not 0
	play(animation, newFlow)
	pass


func playTimeSynced(anim : String = "default") -> void:
	animation = anim #switch anim
	_on_Global_Time_Flow_Has_Changed(Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int), 0,0) #adjust time scale
	# if time is reversed and backwards is false, frame = last frame
	# if timme is reversed and backwards T, frame = first frame #this ones messed up
	# if time is nortmal and backwards F, frame = first
	# if time is normal and backwards T, frame = last

#func switchAnim(anim : String):
	#if not sprite_frames.has_animation(anim): 
		#print("ERROR: animatedSprite has no animation ", anim)
		#return
	#animation = anim
	#frameCountMultiplier = 1
	#secondsPerFrame = 1.0 / sprite_frames.get_animation_speed(animation)
	#indexOfLastFrame = sprite_frames.get_frame_count(animation) - 1

#var count : float = 0
#func _process(delta):
	#if isPlaying: count += delta * Global.currCombatTimeMultiplier * (Global.timeIsNotStopped as int) * frameCountMultiplier
	#if count > secondsPerFrame:
		#if frame == indexOfLastFrame:
			#if sprite_frames.get_animation_loop(animation): frame = 0
			#else: isPlaying = false
		#else:
			#frame = frame + 1
		#count = 0
	#if count < 0:
		#if frame == 0:
			#if sprite_frames.get_animation_loop(animation): 
				#frame = indexOfLastFrame
			#else:
				#isPlaying = false
		#else:
			#frame = frame - 1
		#count = secondsPerFrame

#func set_fps(anim : String, fps : float):
	#sprite_frames.set_animation_speed(anim, fps)
	#if anim == animation : secondsPerFrame = 1.0 / sprite_frames.get_animation_speed(anim)
#func set_anim_duration(anim : String, animDuration : float):
	#sprite_frames.set_animation_speed(anim, sprite_frames.get_frame_count(anim)/animDuration)
	#if anim == animation : secondsPerFrame = 1.0 / sprite_frames.get_animation_speed(anim)
