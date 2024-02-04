extends Node2D


@export var attackPatternFile #imported json file # (String, FILE, "*.json")
@export var attackPatternFile2 #imported json file # (String, FILE, "*.json")
@export var attackPatternFile3 #imported json file # (String, FILE, "*.json")
@onready var attackPatternFilesArray = [attackPatternFile, attackPatternFile2, attackPatternFile3] #just the files
var attackPatternDataArray = [] # the json as strings, can actually be accessed by my code
@export var currEighthNote : int = 0
var JsonLength = 75
@export var bpm = 207
var subdivisionsPerBeat = 2
var secondsPerEigthNote : float
var secondsPerMeasure : float
var eightNotesInAdvance = 0
var reverseEndFXPracticalLength = 2.84
@onready var trackNodes = [$normalMusicLoop, $reverseMusicLoop, $tickingClockFX, $reverseStartFX, $reverseEndFX, $stopEndFX, $speedEndFX, $slowEndFX]
var trackIsActive = [true, false, false, false, false, false, false, false] #does NOT change when time is stopped
var trackProgressions = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
enum {
	NORMALMUSIC
	REVERSEMUSIC
	TICKING
	REVERSESTARTFX
	REVERSEENDFX
	STOPENDFX
	SPEEDENDFX
	SLOWENDFX
}
signal track1(pitch, timeInAdvance) #each corresponds to a note from one of the tracks above
signal track2(pitch, timeInAdvance)
signal track3(pitch, timeInAdvance)
var signalStrings = ["track1", "track2", "track3"]
signal metronome(timeInAdvance)
signal newMeasure()


# Called when the node enters the scene tree for the first time.
func _ready():
	secondsPerEigthNote = (1 / (1.0 * bpm / 60)) / subdivisionsPerBeat
	secondsPerMeasure = 1.0 * bpm / 60 * 4
	for i in range( attackPatternFilesArray.size()):
		attackPatternDataArray.push_back(getAttackPatternData(i))
	play(NORMALMUSIC)
	Global.connect("timeHasChangedSpeed", Callable(self, "syncPitchWithGlobal"))
	Global.connect("timeHasReversed", Callable(self, "timeHasReversed"))
	Global.connect("timeHasStoppedOrStarted", Callable(self, "timeHasStopped"))
#	handleMelodyNote()

var beatCounter : float = 0
var eighthNoteLastFrame : int  = 0
func _process(delta):
	if not Global.timeIsNotStopped:
		return
	for track in range(4):
		if trackIsActive[track]:
			trackProgressions[track] += delta * abs(Global.currCombatTimeMultiplier) * (Global.timeIsNotStopped as int)
	if Global.currCombatTimeMultiplier > 0: #check if a single beat (eight note) has passed
		currEighthNote = (1.0 * trackNodes[NORMALMUSIC].get_playback_position() / secondsPerEigthNote) + eightNotesInAdvance
		if (currEighthNote != eighthNoteLastFrame) and (currEighthNote < JsonLength * 8):
			eighthNoteLastFrame = currEighthNote
			handleBeat()
			if (currEighthNote % 8 == 0):
				emit_signal("newMeasure")
		

func handleBeat():
	emit_signal("metronome", eightNotesInAdvance * secondsPerEigthNote)
	for i in range( attackPatternDataArray.size()): #go through each array of music data
		if (attackPatternDataArray[i][currEighthNote / 8]['note'][currEighthNote % 8] as bool): # if it has a note on this beat that needs to be signaled
				emit_signal(signalStrings[i], (attackPatternDataArray[i][currEighthNote / 8]['pitch'][currEighthNote % 8]) as int, eightNotesInAdvance * secondsPerEigthNote)
				
					
func syncPitchWithGlobal(duration : float, startOfDistortion: bool, _type : bool):
	setAllPitchScales(abs(Global.currCombatTimeMultiplier))
	if startOfDistortion:
		if $speedTimeEndFXTimer.time_left == 0:
			setEndFXTimer(duration, $speedTimeEndFXTimer)
		else:
			setEndFXTimer(duration, $slowTimeEndFXTimer)
	
func timeHasReversed(duration : float, _start : bool):
	if Global.currCombatTimeMultiplier < 0:
		pause(NORMALMUSIC)
		if Global.timeIsNotStopped: $reverseMusicLoop.stream_paused = false
		trackProgressions[REVERSEMUSIC] = $reverseMusicLoop.stream.get_length() - trackProgressions[NORMALMUSIC]
		$reverseMusicLoop.play((1.0 * $reverseMusicLoop.stream.get_length() - trackProgressions[NORMALMUSIC]))
		trackIsActive[REVERSEMUSIC] = true
		play(REVERSESTARTFX)
		play(TICKING)
		setEndFXTimer(duration, $reverseTimeEndFXTimer)
	else:
		pause(REVERSEMUSIC)
		if Global.timeIsNotStopped: $normalMusicLoop.stream_paused = false
		trackProgressions[NORMALMUSIC] = $normalMusicLoop.stream.get_length() - trackProgressions[REVERSEMUSIC]
		$normalMusicLoop.play((1.0 * $normalMusicLoop.stream.get_length() - trackProgressions[REVERSEMUSIC]))
		trackIsActive[NORMALMUSIC] = true
		if Global.timeIsNotStopped: pause(TICKING)
	
func timeHasStopped(duration: float, _start : bool):
	if !Global.timeIsNotStopped: #time IS stopped
		for track in range(4):
			trackNodes[track].stream_paused = true
		play(TICKING)
		setEndFXTimer(duration, $stopTimeEndFXTimer)
	else: #time is flowing
		for track in range(4):
			if trackIsActive[track]:
				play(track)
		pause(TICKING)

func setEndFXTimer(duration : float, timerNode: Timer):
	if reverseEndFXPracticalLength < duration:
		timerNode.wait_time = duration - reverseEndFXPracticalLength
		timerNode.start()
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
	trackHasStopped(REVERSESTARTFX)
func _on_reverseEndFX_finished():
	trackHasStopped(REVERSEENDFX)
func _on_stopEndFX_finished():
	trackHasStopped(STOPENDFX)
func _on_speedEndFX_finished():
	trackHasStopped(SPEEDENDFX)
func _on_slowEndFX_finished():
	trackHasStopped(SLOWENDFX)
func trackHasStopped(trackEnum : int):
	trackProgressions[trackEnum] = 0
	trackIsActive[trackEnum] = false
	
func getAttackPatternData(fileIndex):
	var attackPatternData = File.new() 
	if attackPatternData.file_exists(attackPatternFilesArray[fileIndex]): #get the attack pattern json file from the enemy node
		attackPatternData.open(attackPatternFilesArray[fileIndex], attackPatternData.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(attackPatternData.get_as_text())
		return test_json_conv.get_data()




func _on_stopTimeEndFXTimer_timeout():
	play(STOPENDFX)
func _on_reverseTimeEndFXTimer_timeout():
	play(REVERSEENDFX)
func _on_speedTimeEndFXTimer_timeout():
	play(SPEEDENDFX)
func _on_slowTimeEndFXTimer_timeout():
	play(SLOWENDFX)
