extends CharacterBody2D

var Mode = "normal"
var normalMode = true
var skateboardMode = false
var touchingFloor = is_on_floor()

var normalStateMachine
var skateboardStateMachine
var keySwitch = false

func _ready():
	normalStateMachine = load("res://Entity/Player/States/NormalStates/normalStateMachine.gd").new(self)
	add_child(normalStateMachine)
	skateboardStateMachine = load("res://Entity/Player/States/SkateboardState/skateboardStateMachine.gd").new(self)
	add_child(skateboardStateMachine)

func getInputStates():
	keySwitch = Input.is_action_just_pressed("ability")
	
func checkModes(delta):
	if skateboardMode:
		Mode = "skateboard"
		skateboardStateMachine.update(delta)
	elif normalMode:
		Mode = "normal"
		normalStateMachine.update(delta)
		
func changeModes():
	if keySwitch and Mode == "normal":
		normalMode = false
		skateboardMode = true
		print("Skateboard")
	elif keySwitch and Mode == "skateboard":
		normalMode = true
		skateboardMode = false
		print("Normal")
	
func _physics_process(delta: float) -> void:
	touchingFloor = is_on_floor()
	getInputStates()
	changeModes()
	checkModes(delta)
	move_and_slide()
