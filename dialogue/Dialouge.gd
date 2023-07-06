extends CanvasLayer


export(String, FILE, "*.json") var dialouge_file
var currentDialougeID
var dialouge = []
var isActive = false


func _ready():
	$NinePatchRect.visible = false




func start():
	if isActive:
		return 
	isActive = true
	dialouge = load_dialouge() #get json file w script
	currentDialougeID = -1 #get first line of dialoge and display
	next_script()
	$NinePatchRect.visible = true

func load_dialouge():
	var file = File.new()
	if file.file_exists(dialouge_file):
		file.open(dialouge_file, file.READ)
		return parse_json(file.get_as_text())
		
func _input(event):
	if not isActive: #dont change ID if enter pressed while not active
		return
	if event.is_action_pressed("ui_accept"): #enter key, move to next dialoge box
		next_script()

func next_script():
	currentDialougeID += 1
	if currentDialougeID >= len(dialouge): #reached the end of dialogue
		$CheckForRepeat.start()
		$NinePatchRect.visible = false
		return
	$NinePatchRect/name.text = dialouge[currentDialougeID]['name'] # access the variable name on the first line of the json file
	$NinePatchRect/chat.text = dialouge[currentDialougeID]['text']
	


func _on_CheckForRepeat_timeout():
	isActive = false
