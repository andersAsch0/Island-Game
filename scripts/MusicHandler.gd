extends Node2D


export(String, FILE, "*.json") var attackPatternFile #imported json file
export(String, FILE, "*.json") var attackPatternFile2 #imported json file
export(String, FILE, "*.json") var attackPatternFile3 #imported json file
onready var attackPatternFilesArray = [attackPatternFile, attackPatternFile2, attackPatternFile3] #just the files
var attackPatternDataArray = [] # the json as strings, can actually be accessed by my code
var currEighthNote : int = 0
var JsonLength = 75
export var bpm = 207
var subdivisionsPerBeat = 2
var secondsPerEigthNote : float
var secondsPerMeasure : float
var eightNotesInAdvance = 0
var trackNodes = []
var trackIsActive = [true, false, false, false, false] #does NOT change when time is stopped
var trackProgressions = [0.0, 0.0, 0.0, 0.0, 0.0]
enum {
	NORMALMUSIC
	REVERSEMUSIC
	TICKING
	REVERSESTARTFX
	REVERSEENDFX
}
signal track1(pitch, timeInAdvance) #each corresponds to a note from one of the tracks above
signal track2(pitch, timeInAdvance)
signal track3(pitch, timeInAdvance)
var signalStrings = ["track1", "track2", "track3"]
signal metronome(timeInAdvance)


# Called when the node enters the scene tree for the first time.
func _ready():
	secondsPerEigthNote = (1 / (1.0 * bpm / 60)) / subdivisionsPerBeat
	secondsPerMeasure = 1.0 * bpm / 60 * 4
	trackNodes = [get_node("normalMusicLoop"), get_node("reverseMusicLoop"), get_node("tickingClockFX"), get_node("reverseStartFX"), get_node("reverseEndFX")]
	for i in range( attackPatternFilesArray.size()):
		attackPatternDataArray.push_back(getAttackPatternData(i))
	play(NORMALMUSIC)
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
		



func handleBeat():
	emit_signal("metronome", eightNotesInAdvance * secondsPerEigthNote)
	for i in range( attackPatternDataArray.size()): #go through each array of music data
		if (attackPatternDataArray[i][currEighthNote / 8]['note'][currEighthNote % 8] as bool): # if it has a note on this beat that needs to be signaled
				emit_signal(signalStrings[i], (attackPatternDataArray[i][currEighthNote / 8]['pitch'][currEighthNote % 8]) as int, eightNotesInAdvance * secondsPerEigthNote)

func syncPitchWithGlobal():
	setAllPitchScales(abs(Global.currCombatTimeMultiplier))
func timeHasReversed():
	pause(NORMALMUSIC)
	if Global.timeIsNotStopped: $reverseMusicLoop.stream_paused = false
	trackProgressions[REVERSEMUSIC] = $reverseMusicLoop.stream.get_length() - trackProgressions[NORMALMUSIC]
	$reverseMusicLoop.play((1.0 * $reverseMusicLoop.stream.get_length() - trackProgressions[NORMALMUSIC]))
	trackIsActive[REVERSEMUSIC] = true
	play(REVERSESTARTFX)
	play(TICKING)
func timeHasReversedBack():
	pause(REVERSEMUSIC)
	if Global.timeIsNotStopped: $normalMusicLoop.stream_paused = false
	trackProgressions[NORMALMUSIC] = $normalMusicLoop.stream.get_length() - trackProgressions[REVERSEMUSIC]
	$normalMusicLoop.play((1.0 * $normalMusicLoop.stream.get_length() - trackProgressions[REVERSEMUSIC]))
	trackIsActive[NORMALMUSIC] = true
	if Global.timeIsNotStopped: pause(TICKING)
	
func timeHasStopped():
	for track in range(4):
		trackNodes[track].stream_paused = true
	play(TICKING)
func timeHasResumed():
	for track in range(4):
		if trackIsActive[track]:
			play(track)
	pause(TICKING)

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

func getAttackPatternData(fileIndex):
	var attackPatternData = File.new() 
	if attackPatternData.file_exists(attackPatternFilesArray[fileIndex]): #get the attack pattern json file from the enemy node
		attackPatternData.open(attackPatternFilesArray[fileIndex], attackPatternData.READ)
		return parse_json(attackPatternData.get_as_text())
