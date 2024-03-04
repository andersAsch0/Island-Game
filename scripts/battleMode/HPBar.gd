class_name HPBar
extends ProgressBar

var nodeOfInterest: Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if owner.has_signal("updateHP"):
		owner.connect("updateHP", Callable(self, "updateHP"))
		nodeOfInterest = owner
	elif get_parent().has_signal("updateHP"):
		get_parent().connect("updateHP", Callable(self, "updateHP"))
		nodeOfInterest = get_parent()
	value = max_value
		

##needs two arguments
func updateHP(currentHP:float, maxHP:float):
	value = currentHP / maxHP * max_value
