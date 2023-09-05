extends Node

#each enemy will have a unique musicAttackController scene. 
#Each one, though, will have the same MusicHandler child, which must be passed the correct music and correct music/attack data
export var bulletPackedScene : PackedScene
signal gridAttack(xPos, yPos)
signal bulletAttack(pos)
signal laserAttack(pos)

#variables that may be different for dfferent battles or tracks, must be set up and passed to musicHandler
var bpm = 207
var eigthNotesInAdvance = 4 # how many eightnotes in advance does the warning animation play before spawning the attack
var totalMeasuresInSong = 76
func _ready():
	$MusicHandler.bpm = bpm
	$MusicHandler.JsonLength = totalMeasuresInSong - 1
	$MusicHandler.eightNotesInAdvance = eigthNotesInAdvance

var count : int = 0
func on_track_1(pitch, timeInAdvance = 0.0): #grid attack
	$gridAttack.attack(melodyPattern[count % 9].x, melodyPattern[count % 9].y, timeInAdvance)
	count += 1

var bulletXLocations = [50, 100, 150]
var bullet
func on_track_2(pitch, timeInAdvance = 0.0): #bullet attack
	bullet = bulletPackedScene.instance()
	bullet.position = Vector2(bulletXLocations[pitch % 3], 50)
	bullet.warningAnimationTime = timeInAdvance
	call_deferred("add_child", bullet)
	

var melodyPattern = [Vector2(1,1),Vector2(1,0),Vector2(1,2),Vector2(1,1),Vector2(0,2),Vector2(0,0),Vector2(2,2),Vector2(2,0), Vector2(1,1)]
func _on_MusicHandler_musicStart():
	pass # Replace with function body.
