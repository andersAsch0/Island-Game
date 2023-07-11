extends KinematicBody2D

export var bulletScene : PackedScene #packed scene of the bullet this enemy uses
var bullet = null
export var approachTime = 2 # how long in seconds enemy takes to approach
export(String, FILE, "*.json") var attackPatternFile #imported json file
var attackPatternData #json file in text form so I can use it
var approaching = false
var origScale = 0.1 # starting size of sprite when enemy spawns
export var finalScale = 1 #final size of the sprite once it has approached
var loopStart = 1 #line of the json where the enemies continous attack loop starts
var loopEnd = 2
var currAttack = 1 #current line of json file
var bulletTimeMultiplier = 1 #always multiplied onto bullets speed when they are spawned, when time is reversed, this is changed to -1

#SETUP AND APPROACH

func _ready():
	$ApproachTimer.wait_time = approachTime
	$ApproachTimer.start()
	$AnimatedSprite.play("moving")
func approach(): #when called (by outside battleMode script), enemy does whatever it needs to do at beginning of fight
	$AnimatedSprite.scale.x = origScale
	$AnimatedSprite.scale.y = origScale
	visible = true
	approaching = true #usually, that will be to slowly approach
func _physics_process(delta):
	if approaching: #increase scale (grow bigger each frame)
		$AnimatedSprite.scale.x += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta 
		$AnimatedSprite.scale.y += ((finalScale - origScale)/$ApproachTimer.wait_time) * delta
func _on_ApproachTimer_timeout(): #when timer finishes, sprite is proper size
	approaching = false #stop growing
	$AnimatedSprite.play("idle")
	introduction()
	startFight()
func introduction():
	pass
	#dialouge? noise? pause? animation? something instead of fight instantly starting


#FIGHT AND BULLET SPAWNING

func startFight():
	attackPatternData = getAttackPatternData() #get the json file and get it as a string
	loopStart = attackPatternData[0]['loopStart'] #iterated through json file
	loopEnd = attackPatternData[0]['loopEnd']
	currAttack = loopStart
	attack()
func attack():
	$bulletSpawnTimer.wait_time = attackPatternData[currAttack]['waitTime'] #time in between bullets spawning
	$bulletSpawnTimer.start()
func _on_bulletSpawnTimer_timeout():
	bullet = bulletScene.instance()
	bullet.position.x = attackPatternData[currAttack]['spawnLocationX'] - position.x
	bullet.position.y = $bulletSpawnLocationY.position.y - position.y
	bullet.speed *= bulletTimeMultiplier
	add_child(bullet)
	currAttack += 1
	if currAttack > loopEnd:
		currAttack = loopStart
	attack()
	

func reverseTime():
	bulletTimeMultiplier *= -1 
	
#HELPER

func getAttackPatternData():
	attackPatternData = File.new() 
	if attackPatternData.file_exists(attackPatternFile): #get the attack pattern json file from the enemy node
		attackPatternData.open(attackPatternFile, attackPatternData.READ)
		return parse_json(attackPatternData.get_as_text())





