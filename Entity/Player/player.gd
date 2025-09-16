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

var dashes = 0
var dashCooldownTime = 0.1
var dashDirection: Vector2
var maxDashes = 1
var dashSpeed = 1200
var dashAccel = 4
var dashTime = 0.25
var dashBufferTime = 0.075
var dashMomentumCarry = 0.5
var storedDashMomentum = 0
var canUseDashMomentum = false
var maxStoredMomentum = 4000

var squishX = 1.0
var squishY = 1.0
var squishStep = 0.08

var keyUp = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyDashPressed = false
var keyJumpPressed = false

var amtOfJumps = 1
var jumpCounter = amtOfJumps
var jumpPower = -500
var variableJumpMultiplier := 0.75
var jumpBufferTime = 0.15
var coyoteTime = 0.1
var bhTime = 0.1

var currentState = null
var previousState = null
var nextState = null

var ui_scene = preload("res://scenes/MomentumGauge.tscn").instantiate()

@onready var Collider = $Collider
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Camera = $Camera
@onready var States = $StateMachine
@onready var jumpBufferTimer = $Timers/JumpBufferTimer
@onready var bunnyHopTimer = $Timers/BunnyHopTimer
@onready var coyoteTimer = $Timers/CoyoteTimer
@onready var dashTimer: Timer = $Timers/DashTimer
@onready var dashBuffer: Timer = $Timers/DashBuffer
@onready var dashCooldownTimer: Timer = $Timers/DashCooldown
@onready var dashGhost: CPUParticles2D = $GraphicsEffects/Dash/DashTrail
@onready var momentumUI
@onready var runningSound = $Sounds/Running
@onready var jumpSound = $Sounds/Jumping

func _ready():
	Engine.time_scale = 1 #Slow or speed up the engine speed, for debugging
	for state in States.get_children():
		state.States = States
		state.Player = self
	previousState = States.Fall
	currentState = States.Fall
	setSquish(1.0, 1.0)
	get_parent().call_deferred("add_child", ui_scene)
	momentumUI = ui_scene

func UpdateMomentumUI(value: float, max_value: float):
	self.value = clamp(value, 0, max_value)

func handleIdle():
	if is_on_floor():
		ChangeState(States.Idle)

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
	runningSound.play()
	if xDirection and is_on_floor():
		playerVelocity.x = xDirection * runSpeed
		velocity.x = move_toward(velocity.x, playerVelocity.x, acceleration)
	elif xDirection and not is_on_floor():
		playerVelocity.x = xDirection * runSpeed
		velocity.x = move_toward(velocity.x, playerVelocity.x, acceleration / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, runSpeed)

func handleFall():
	if !is_on_floor():
		coyoteTimer.start(coyoteTime)
		ChangeState(States.Fall)

func handleLanding():
	if is_on_floor() and jumpBufferTimer.time_left <= 0:
		dashes = 0
		ChangeState(States.Idle)
	elif is_on_floor() and jumpBufferTimer.time_left > 0:
		ChangeState(States.Jump)

func handleDash():
	if dashes < maxDashes:
		if keyDashPressed:
			if dashTimer.time_left <= 0:
				dashTimer.start(dashBufferTime)
				await dashTimer.timeout
				dashes += 1
				ChangeState(States.Dash)

func getDashDirection() -> Vector2:
	var _dir = Vector2.ZERO
	if !keyLeft and !keyRight and !keyUp and !keyDown:
		_dir = Vector2(directionFacing, 0)
	else:
		_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("lookUp", "lookDown"))
	return _dir
		
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
	keyDashPressed = Input.is_action_just_pressed("dash")
	
	if keyRight: directionFacing = 1
	if keyLeft: directionFacing = -1

func handleFlipH():
	Sprite.flip_h = (directionFacing < 0)

func updateSquish(): 
	Sprite.scale.x = squishX
	Sprite.scale.y = squishY
	
	if squishX != 1.0: squishX = move_toward(squishX, 1.0, squishStep)
	if squishY != 1.0: squishY = move_toward(squishY, 1.0, squishStep)

func setSquish(_squishX: float = 1.0, _squishY: float = 1.0, _step: float = squishStep):
	squishX = _squishX if (_squishX != 0) else 1.0
	squishY = _squishY if (_squishY != 0) else 1.0
	squishStep = _step if (_step != 0) else squishStep
	

func _draw():
	currentState.Draw()

func ChangeState(targetState):
	if targetState:
		nextState = targetState

func handleStateChange():
	if nextState != null:
		if currentState != nextState:
			previousState = currentState
			currentState.ExitState()
			currentState = null
			currentState = nextState
			currentState.EnterState()
		nextState = null
	
func _physics_process(delta):
	getInputStates()
	handleTerminalVelocity()
	currentState.Update(delta)
	move_and_slide()
	updateSquish()
	handleStateChange()
