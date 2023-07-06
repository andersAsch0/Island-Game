extends Node2D

export var enemyScene : PackedScene
var enemy
var enemyAttackPatternJson #File object
var attackPatternData = [] #string
var currAttack = 1#int representing current line in json file
var loopStart = 1
var loopEnd = 2

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
	attackPatternData = getAttackPatternData() #get the json file and get it as a string
	loopStart = attackPatternData[0]['loopStart']
	loopEnd = attackPatternData[0]['loopEnd']
	currAttack = loopStart
	attack()

func attack():
	$bulletSpawnTimer.wait_time = attackPatternData[currAttack]['waitTime']
	$bulletSpawnTimer.start()
	
func _on_bulletSpawnTimer_timeout():
	print("spawningg bullet at ", attackPatternData[currAttack]['spawnLocationX'], ", json line ", currAttack)
	currAttack += 1
	if currAttack > loopEnd:
		currAttack = loopStart
	attack()
	
	
	
func getAttackPatternData():
	enemyAttackPatternJson = File.new() 
	if enemyAttackPatternJson.file_exists($BattleModeEnemy.attackPatternFile): #get the attack pattern json file from the enemy node
		enemyAttackPatternJson.open($BattleModeEnemy.attackPatternFile, enemyAttackPatternJson.READ)
		return parse_json(enemyAttackPatternJson.get_as_text())
	

