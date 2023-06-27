extends KinematicBody2D
#state nachine time
enum { #states
	IDLE,
	PICK_DIRECTION,
	MOVE 
	#TALK or whatever
}
const speed = 20
export var bounds = 5
var curr_state = IDLE
var directions = [ Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
var animations = ["right", "left", "up", "down"]
var idle_animations = ["idle_looking_right","idle_looking_left","idle_looking_up","idle_looking_down" ]
var choice = 0 # choice of direction currently, bad name oops
var start_pos #limit npcs movement to one area

func _process(delta):
	# print("Curr state =", curr_state)
	match curr_state: # do stuff according to whatever state its in
		IDLE:
			$AnimatedSprite.play(idle_animations[choice])
		PICK_DIRECTION:
			choice = choose([0,1,2,3])
		MOVE:
			move(delta)
			
func _ready():
	randomize() # randomize seed for pseudo rand num generator, so npc does different thing each time
	start_pos = position

func move(delta):
	position += directions[choice] * speed * delta
	$AnimatedSprite.play(animations[choice])
	if abs(position.x - start_pos.x) > bounds:
		curr_state = IDLE
		position.x = sign(position.x - start_pos.x) * bounds + start_pos.x
	if abs(position.y - start_pos.y) > bounds:
		curr_state = IDLE
		position.y = sign(position.y - start_pos.y) * bounds + start_pos.y	


func choose(array): #choose random from array
	return array[randi() % array.size()]

func _on_Timer_timeout(): #pick new state when timer runs out (like tick)
	$Timer.wait_time = choose([0.5, 1, 1.5])
	curr_state = choose([IDLE, PICK_DIRECTION, MOVE])
