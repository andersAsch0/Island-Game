class_name SceneTransition

extends Area2D

@export var destinationPath = ""
@export var entryPointNum = 0 #ID for game to know which entry into the destination scene this corresponds to (since a scene could have multiple entrypoints)
#@export var destinationNum = 0 #ID for this specific entry point (ex. for door to know to close when player enters scene through it)
@export var cooldown : float = 0.7 #how long after the scene is entered does the player have to wait before being able to leave
var enabled: bool = false
signal transitionTaken
signal enteredThrough

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	
func _process(delta):
	cooldown -= delta
	if cooldown <= 0:
		enabled = true
		set_process(false)
	
func _on_area_entered(hitbox: HitBox): #passes in null if not hitbox
	if hitbox and enabled: #only proceed if it is a hitbox
		emit_signal("transitionTaken")
		if destinationPath != "":
			Global.call_deferred("switchOverworldScene", entryPointNum, destinationPath)

func setCollisionLayer(layer:int):
	collision_layer = layer
	
func playerEnteredSceneThrough():
	emit_signal("enteredThrough")
