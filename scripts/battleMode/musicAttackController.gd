extends Node

#each enemy will have a unique musicAttackController scene. 
#Each one, though, will have the same MusicHandler child, which must be passed the correct music and correct music/attack data

signal gridAttack(xPos, yPos)
signal bulletAttack(pos)
signal laserAttack(pos)


func on_track_1(timeInAdvance, pitch):
	pass

func on_track_2(timeInAdvance, pitch):
	pass
	
func on_track_3(timeInAdvance, pitch):
	pass

func on_track_4(timeInAdvance, pitch):
	pass

func on_track_5(timeInAdvance, pitch):
	pass
