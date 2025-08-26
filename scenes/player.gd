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
var gravityForce = 1600
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

@onready var Collider = $Collider
@onready var Sprite = $Sprite
@onready var Animator = $Animator

#endregion

#region State Handling
	#region Idle Handling
func handleIdle():
	jumpCounter = amtOfJumps
	if keyRight or keyLeft:
		state = playerState.run
	if keyJumpPressed and jumpCounter > 0:
		state = playerState.jump_start
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
func handleRun():
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
	playerVelocity.x = xDirection * runSpeed
	velocity.x = playerVelocity.x
	if jumpCounter > 0 and keyJumpPressed:
		state = playerState.jump_start
	if is_on_floor():
		state = playerState.idle
#endregion
	#region Dash Handling
func handleDash():
	pass
#endregion
#endregion

func handleGravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

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
	Sprite.flip_h = (directionFacing < 0)
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

func _physics_process(delta):
	getInputStates()
	handleGravity(delta)
	handleAnimation()
	
	match state:
		playerState.idle:
			handleIdle()
			
		playerState.jump_start:
			handleJump_Start()
			
		playerState.jump_air:
			handleJump_Air()
				
		playerState.run:
			handleRun()
				
		playerState.fall:
			handleFall()
			
		playerState.dash:
			handleDash()
				
	move_and_slide()
