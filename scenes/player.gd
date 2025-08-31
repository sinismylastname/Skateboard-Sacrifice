extends CharacterBody2D

#region Variables
#need states for a lot of stuff, like start_dash, mid_dash, end_dash
enum playerState {idle, run, jump_start, jump_air, fall, dash}

var state = playerState.idle
var playerVelocity = Vector2.ZERO
var yDirection = Input.get_axis("right", "left")
var xDirection = Input.get_axis("left", "right")
var allDirection = Input.get_vector("left", "right", "lookUp", "lookDown")
var directionFacing = 1

var runSpeed = 400
var gravityForce = 980
var acceleration = 40

var keyUp = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyJumpPressed = false

var amtOfJumps = 2
var jumpCounter = amtOfJumps
var jumpPower = -400

var currentState = null
var previousState = null

@onready var Collider = $Collider
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Camera = $Camera
@onready var States = $StateMachine

#endregion

#region State Handling
	#region Idle Handling
func handleIdle():
	if is_on_floor():
		jumpCounter = amtOfJumps
		ChangeState(States.Idle)
#endregion
	#region Jump Handling
func handleJump_Start():
	jumpCounter -= 1
	velocity.y = jumpPower
	state = playerState.jump_air
func handleJump_Air():
	playerVelocity.x = xDirection * runSpeed
	velocity.x = playerVelocity.x
	if is_on_floor():
		state = playerState.idle
		return
	if jumpCounter > 0 and keyJumpPressed:
		state = playerState.jump_start
		return
	elif velocity.y > 0:
		state = playerState.fall

#endregion
	#region Run Handling
func handleHorizontalMovement():
	jumpCounter = amtOfJumps
	if xDirection:
		playerVelocity.x = xDirection * runSpeed
		velocity.x = move_toward(velocity.x, playerVelocity.x, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, runSpeed)
	if keyJumpPressed and jumpCounter > 0:
		state = playerState.jump_start
	if not Input.is_anything_pressed():
		state = playerState.idle
#endregion
	#region Fall Handling
func handleFall():
	if !is_on_floor():
		ChangeState(States.Fall)
#endregion
	#region Dash Handling
func handleDash():
	pass
#endregion
#endregion

func _ready():
	for state in States.get_children():
		state.States = States
		state.Player = self
	previousState = States.Fall
	currentState = States.Fall

func handleGravity(delta, gravity: float = gravityForce):
	if not is_on_floor():
		velocity += gravity * delta

func getInputStates():
	xDirection = Input.get_axis("left", "right")
	yDirection = Input.get_axis("right", "left")
	keyUp = Input.is_action_pressed("lookUp")
	keyDown = Input.is_action_pressed("lookDown")
	keyLeft = Input.is_action_pressed("left")
	keyRight = Input.is_action_pressed("right")
	keyJump = Input.is_action_pressed("jump")
	keyJumpPressed = Input.is_action_just_pressed("jump")
	
	if keyRight: directionFacing = 1
	if keyLeft: directionFacing = -1

func handleAnimation():
	if is_on_floor():
		if velocity.x != 0:
			Animator.play("walk")
		else:
			Animator.play("idle")
	else:
		if velocity.y < 0:
			Animator.play("fall") #jump anim is bugged rn
		else:
			Animator.play("fall")

func handleFlipH():
	Sprite.flip_h = (directionFacing < 0)

func _draw():
	currentState.Draw()

func ChangeState(newState):
	if newState != null:
		previousState = currentState
		currentState = newState
		previousState = newState
		previousState.ExitState()
		currentState.EndState()
		print("State Change From " + previousState + " to: " + currentState)
		

func _physics_process(delta):
	getInputStates()
	handleGravity(delta)
	handleAnimation()
	handleFlipH()
	currentState.Update()
	
	match state:
		playerState.idle:
			handleIdle()
			
		playerState.jump_start:
			handleJump_Start()
			
		playerState.jump_air:
			handleJump_Air()
				
		playerState.run:
			handleHorizontalMovement()
				
		playerState.fall:
			handleFall()
			
		playerState.dash:
			handleDash()
				
	move_and_slide()
