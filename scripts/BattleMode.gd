extends Node2D

export var enemyScene : PackedScene
var enemy

func _ready(): #this script sets up enemy, approach() function will handle the rest
	enemy = enemyScene.instance()
	enemy.position = $enemySpawnLocation.position
	enemy.scale.x = 0.2 #starting scale
	enemy.scale.y = 0.2
	add_child(enemy) # add node to scene
	
	 # connect the signal to start fight from the new node to this one
	enemy.connect("startFight", self, "_on_BattleModeEnemy_startFight")
	
	enemy.approach()


func _on_BattleModeEnemy_startFight():
	print("starting fight")
