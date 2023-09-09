extends Node

#each enemy will have a unique musicAttackController scene. 
#Each one, though, will have the same MusicHandler child, which must be passed the correct music and correct music/attack data
export var bulletPackedScene : PackedScene
export var laserPackedScene : PackedScene
export var laserBulletScene : PackedScene

#variables that may be different for dfferent battles or tracks, must be set up and passed to musicHandler
var bpm = 207
var eigthNotesInAdvance = 2 # how many eightnotes in advance does the warning animation play before spawning the attack
var totalMeasuresInSong = 76
var isDefenseMode = false
func _ready():
	$MusicHandler.bpm = bpm
	$MusicHandler.JsonLength = totalMeasuresInSong - 1
	$MusicHandler.eightNotesInAdvance = eigthNotesInAdvance


var count : int = eigthNotesInAdvance
var gridAttackPattern = [[Vector2(1,0), Vector2(1,1), Vector2(1,2)], [], [], [], [Vector2(0,1), Vector2(1,1), Vector2(2, 1)], [], [], [], [Vector2(0, 2)], [], [Vector2(0,0)], [], [Vector2(2, 0)], [], [Vector2(2, 2)], []]
func _on_MusicHandler_metronome(timeInAdvance): # grid attack
	if isDefenseMode:
		for vec in gridAttackPattern[count % 16]:
			$gridAttack.attack(vec.x, vec.y, timeInAdvance)
	count += 1
func on_track_1(pitch, timeInAdvance = 0.0):
	if isDefenseMode:
		pass
onready var bulletXLocations = [$gridAttack/grid00.position.x, $gridAttack/grid10.position.x, $gridAttack/grid20.position.x]
var bullet
func on_track_2(pitch, timeInAdvance = 0.0): #bullet attack
	temp += 1
	if isDefenseMode:
		bullet = bulletPackedScene.instance()
		bullet.position = Vector2(bulletXLocations[pitch % 3], 0)
		bullet.warningAnimationTime = timeInAdvance
		call_deferred("add_child", bullet)
func on_track_3(pitch, timeInAdvance = 0.0): #laser attack
	if isDefenseMode: 
		var laserNode = laserPackedScene.instance()
		laserNode.lengthOfWarningSeconds = timeInAdvance
		laserNode.bulletPackedScene = laserBulletScene
		laserNode.position = Vector2(bulletXLocations[pitch % 3], 0)
		add_child(laserNode)	
		
func fireLaser():
	var laserNode = laserPackedScene.instance()
	laserNode.lengthOfWarningSeconds = 2
	laserNode.bulletPackedScene = laserBulletScene
	add_child(laserNode)	
	pass

func _on_MusicHandler_musicStart():
	pass # Replace with function body.

var temp  = 0
func offenseModeStarting(): #called when enemy starts absconding
	isDefenseMode = false
	temp += 1
func defenseModeStarting(): #called when enemy starts attacking (after anglechange)
	isDefenseMode = true
	temp += 1
