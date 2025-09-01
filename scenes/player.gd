extends CharacterBody2D

#region Variables
#need states for a lot of stuff, like start_dash, mid_dash, end_dash

var playerVelocity = Vector2.ZERO
var yDirection = Input.get_axis("right", "left")
var xDirection = Input.get_axis("left", "right")
var allDirection = Input.get_vector("left", "right", "lookUp", "lookDown")
var directionFacing = 1

var runSpeed := 400
var gravityForceJump := 980
var gravityForceFall := 1280
var terminalVelocity := 1600
var acceleration := 40

var keyUp = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyJumpPressed = false

var amtOfJumps = 1
var jumpCounter = amtOfJumps
var jumpPower = -525
var variableJumpMultiplier := 0.75
var jumpBufferTime = 0.45
var coyoteTime = 0.1

var currentState = null
var previousState = null

@onready var Collider = $Collider
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Camera = $Camera
@onready var States = $StateMachine
@onready var jumpBufferTimer = $Timers/JumpBufferTimer
@onready var coyoteTimer = $Timers/CoyoteTimer
#endregion

func _ready():
	Engine.time_scale = 1 #Slow or speed up the engine speed, for debugging
	for state in States.get_children():
		state.States = States
		state.Player = self
	previousState = States.Fall
	currentState = States.Fall

#region State Handling
	#region Idle Handling
func handleIdle():
	if is_on_floor():
		ChangeState(States.Idle)
#endregion
	#region Jump Handling
func handleJump():
	if is_on_floor():
		if jumpCounter > 0:
			if keyJumpPressed:
				jumpBufferTimer.stop()
				jumpCounter -= 1
				ChangeState(States.Jump)
			if (jumpBufferTimer.time_left > 0):
				jumpCounter -= 1
				jumpBufferTimer.stop()
				ChangeState(States.Jump)
	else:
		if jumpCounter > 0 and jumpCounter < amtOfJumps and keyJumpPressed:
			jumpCounter -= 1
			ChangeState(States.Jump)
			
		if coyoteTimer.time_left > 0:
			if keyJumpPressed and jumpCounter > 0:
				coyoteTimer.stop()
				jumpCounter -= 1
				ChangeState(States.Jump)

func handleJumpBuffer():
	if keyJumpPressed:
		jumpBufferTimer.start(jumpBufferTime)

func handleHorizontalMovement():
	if xDirection:
		playerVelocity.x = xDirection * runSpeed
		velocity.x = move_toward(velocity.x, playerVelocity.x, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, runSpeed)

func handleFall():
	if !is_on_floor():
		coyoteTimer.start(coyoteTime)
		ChangeState(States.Fall)

func handleLanding():
	if is_on_floor():
		ChangeState(States.Idle)

func handleDash():
	pass

func handleGravity(delta, gravity: float = gravityForceJump):
	if not is_on_floor():
		velocity.y += gravity * delta

func handleTerminalVelocity():
	if velocity.y > terminalVelocity: velocity.y = terminalVelocity

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

func handleFlipH():
	Sprite.flip_h = (directionFacing < 0)

func _draw():
	currentState.Draw()

func ChangeState(newState):
	if newState != null:
		previousState = currentState
		currentState = newState
		previousState.ExitState()
		currentState.EnterState()
		return
		#print("State Change From " + previousState.Name + " to: " + currentState.Name)
		

func _physics_process(delta):
	getInputStates()
	handleGravity(delta)
	handleFlipH()
	handleTerminalVelocity()
	currentState.Update(delta)
	move_and_slide()
