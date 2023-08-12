extends Node2D


# Declare member variables here. Examples:
var bpm = 30
var subdivisionsPerBeat = 2
enum {
	NORMALMUSIC
	REVERSEMUSIC
	TICKING
	REVERSESTARTFX
	REVERSEENDFX
}
var trackNodes = []
var trackIsActive = [true, false, false, false, false] #does NOT change when time is stopped
var trackProgressions = [0.0, 0.0, 0.0, 0.0, 0.0]

# Called when the node enters the scene tree for the first time.
func _ready():
	trackNodes = [get_node("normalMusicLoop"), get_node("reverseMusicLoop"), get_node("tickingClockFX"), get_node("reverseStartFX"), get_node("reverseEndFX")]
	play(NORMALMUSIC)

func _process(delta):
	for track in range(4):
		if trackIsActive[track]:
			trackProgressions[track] += delta * abs(Global.currCombatTimeMultiplier) * (Global.timeIsNotStopped as int)
#	print("NORMAL: " , trackProgressions[NORMALMUSIC], " REVERSE : ", trackProgressions[REVERSEMUSIC])

func syncPitchWithGlobal():
	setAllPitchScales(abs(Global.currCombatTimeMultiplier))
func timeHasReversed():
	pause(NORMALMUSIC)
	$reverseMusicLoop.stream_paused = false
	trackProgressions[REVERSEMUSIC] = $reverseMusicLoop.stream.get_length() - trackProgressions[NORMALMUSIC]
	$reverseMusicLoop.play((1.0 * $reverseMusicLoop.stream.get_length() - trackProgressions[NORMALMUSIC]))
	trackIsActive[REVERSEMUSIC] = true
	play(REVERSESTARTFX)
	play(TICKING)
func timeHasReversedBack():
	pause(REVERSEMUSIC)
	$normalMusicLoop.stream_paused = false
	trackProgressions[NORMALMUSIC] = $normalMusicLoop.stream.get_length() - trackProgressions[REVERSEMUSIC]
	$normalMusicLoop.play((1.0 * $normalMusicLoop.stream.get_length() - trackProgressions[REVERSEMUSIC]))
	trackIsActive[NORMALMUSIC] = true
	pause(TICKING)
	
func timeHasStopped():
	$normalMusicLoop.stream_paused=true #replace w trackNodes[]
	$reverseMusicLoop.stream_paused=true
	$reverseStartFX.stream_paused=true
	$reverseEndFX.stream_paused=true
	$tickingClockFX.stream_paused=true
func timeHasResumed():
	for track in range(4):
		if trackIsActive[track]:
			play(track)

func setAllPitchScales(newScale : float):
	$normalMusicLoop.pitch_scale = newScale
	$reverseEndFX.pitch_scale = newScale
	$reverseMusicLoop.pitch_scale = newScale
	$reverseStartFX.pitch_scale = newScale
	$tickingClockFX.pitch_scale = newScale

func play(trackEnum):
	trackNodes[trackEnum].stream_paused = false
	trackNodes[trackEnum].play(trackProgressions[trackEnum])
	trackIsActive[trackEnum] = true
func pause(trackEnum):
	trackNodes[trackEnum].stream_paused = true
	trackIsActive[trackEnum] = false

func _on_normalMusicLoop_finished():
	trackProgressions[NORMALMUSIC] = 0
	trackNodes[NORMALMUSIC].play()
func _on_reverseMusicLoop_finished():
	trackProgressions[REVERSEMUSIC] = 0
	trackNodes[REVERSEMUSIC].play()
func _on_tickingClockFX_finished():
	trackProgressions[TICKING] = 0
	trackNodes[TICKING].play()
func _on_reverseStartFX_finished():
	trackProgressions[REVERSESTARTFX] = 0
	trackIsActive[REVERSESTARTFX] = false
func _on_reverseEndFX_finished():
	trackProgressions[REVERSEENDFX] = 0
	trackIsActive[REVERSEENDFX] = false
