extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func hit():
	playAnim("hit")

func miss():
	playAnim("miss")

func playAnim(name):
	position = Global.getEnemyCoords()
	play(name)
	frame = 0



func _on_comboMiniGame_successfulCombo(damage):
	if abs(Global.getEnemyDisplacementFromPlayer().x) <= 1 and  abs(Global.getEnemyDisplacementFromPlayer().y) <= 1:
		hit()
	else: 
		miss()


func _on_comboMiniGame_failedCombo():
	miss()
