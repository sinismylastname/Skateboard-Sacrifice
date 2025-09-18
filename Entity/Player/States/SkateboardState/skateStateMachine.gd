extends Node

var playerVelocity = Vector2.ZERO
var yDirection = Input.get_axis("lookUp", "lookDown")
var xDirection = Input.get_axis("left", "right")
var allDirection = Input.get_vector("left", "right", "lookUp", "lookDown")
var directionFacing = 1

var runSpeed := 400
var gravityForceJump := 980
var gravityForceFall := 1280
var terminalVelocity := 1600
var acceleration := 40
var velocity
var touchingFloor

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

var keyUp = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyTrickPressed = false
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

var Collider 
var Sprite 
var Animator 
var Camera 
var normalStates 
var jumpBufferTimer 
var coyoteTimer
var dashTimer
var dashBuffer
var dashCooldownTimer
var dashGhost
var momentumUI
var runningSound 
var jumpSound 
var Player

var Idle 
var Run 
var Dash 
var Fall 
var Jump

func _init(player):
	Player = player
	Collider = Player.get_node("Collider")
	Sprite = Player.get_node("Sprite")
	Animator = Player.get_node("Animator")
	Camera = Player.get_node("Camera")
	normalStates = Player.get_node("StateMachine/Normal")
	jumpBufferTimer = Player.get_node("Timers/JumpBufferTimer")
	coyoteTimer = Player.get_node("Timers/CoyoteTimer")
	dashTimer = Player.get_node("Timers/DashTimer")
	dashBuffer = Player.get_node("Timers/DashBuffer")
	dashCooldownTimer = Player.get_node("Timers/DashCooldown")
	dashGhost = Player.get_node("GraphicsEffects/Dash/DashTrail")
	
	for state in normalStates.get_children():
		state.States = normalStates
		state.Player = Player
		state.Machine = self
		#state.Idle = normalStates.get_node("Idle")
		#state.Run = normalStates.get_node("Run")
		#state.Dash = normalStates.get_node("Dash")
		#state.Fall = normalStates.get_node("Fall")
		#state.Jump = normalStates.get_node("Jump")

func _ready():
	Idle = normalStates.get_node("Idle")
	Run = normalStates.get_node("Run")
	Dash = normalStates.get_node("Dash")
	Fall = normalStates.get_node("Fall")
	Jump = normalStates.get_node("Jump")
	
	previousState = Fall
	currentState = Fall
	currentState.EnterState()
	
	Engine.time_scale = 1 #Slow or speed up the engine speed, for debugging

	get_parent().call_deferred("add_child", ui_scene)
	momentumUI = ui_scene

func UpdateMomentumUI(value: float, max_value: float):
	self.value = clamp(value, 0, max_value)

func handleIdle():
	if touchingFloor:
		ChangeState(Idle)

func handleJump():
	if touchingFloor:
		if jumpCounter > 0:
			if keyJumpPressed:
				jumpBufferTimer.stop()
				jumpCounter -= 1
				ChangeState(Jump)
			if (jumpBufferTimer.time_left > 0):
				jumpCounter -= 1
				jumpBufferTimer.stop()
				ChangeState(Jump)
	else:
		if jumpCounter > 0 and jumpCounter < amtOfJumps and keyJumpPressed:
			jumpCounter -= 1
			ChangeState(Jump)
			
		if coyoteTimer.time_left > 0:
			if keyJumpPressed and jumpCounter > 0:
				coyoteTimer.stop()
				jumpCounter -= 1
				ChangeState(Jump)

func handleJumpBuffer():
	if keyJumpPressed:
		jumpBufferTimer.start(jumpBufferTime)

func handleHorizontalMovement():
	#runningSound.play()
	if xDirection and touchingFloor:
		playerVelocity.x = xDirection * runSpeed
		velocity.x = move_toward(velocity.x, playerVelocity.x, acceleration)
	elif xDirection and not touchingFloor:
		playerVelocity.x = xDirection * runSpeed
		velocity.x = move_toward(velocity.x, playerVelocity.x, acceleration / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, runSpeed)

func handleFall():
	if !touchingFloor:
		coyoteTimer.start(coyoteTime)
		ChangeState(Fall)

func handleLanding():
	if touchingFloor and jumpBufferTimer.time_left <= 0:
		dashes = 0
		ChangeState(Idle)
	elif touchingFloor and jumpBufferTimer.time_left > 0:
		ChangeState(Jump)

func handleTricks():
	if keyTrickPressed and (keyRight or keyLeft):
		print("kickflip")
	elif keyTrickPressed and keyUp:
		print("ollie")
	elif keyTrickPressed and keyDown:
		print("idk what this trick is called lol")

'''func getDashDirection() -> Vector2:
	var _dir = Vector2.ZERO
	if !keyLeft and !keyRight and !keyUp and !keyDown:
		_dir = Vector2(directionFacing, 0)
	else:
		_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("lookUp", "lookDown"))
	return _dir''' #commented out for now because i am not sure if i want tricks to have directions?
		
func handleGravity(delta, gravity: float = gravityForceJump):
	if not touchingFloor:
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
	keyTrickPressed = Input.is_action_just_pressed("dash")
	
	if keyRight: directionFacing = 1
	if keyLeft: directionFacing = -1

func handleFlipH():
	Sprite.flip_h = (directionFacing < 0)

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
	
func update(delta):
	touchingFloor = Player.touchingFloor
	velocity = Player.velocity
	getInputStates()
	handleTerminalVelocity()
	currentState.Update(delta)
	handleStateChange()
	Player.velocity = velocity
