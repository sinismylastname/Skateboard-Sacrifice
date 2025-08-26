extends CharacterBody2D

var screenWidth = 1152

var horiDirection = Input.get_axis("left", "right")
var allDirection = Input.get_vector("left","right","lookUp","lookDown")
var targetVelocity

var acceleration = 1600
const gravityForce = 1200
var friction = 8000
var maxSpeed = 800
var storedMomentum = Vector2.ZERO

var dashInput = Input.is_action_just_pressed("dash")
var dashing = false
var dashDuration = 0
var dashSpeed = 1250
var dashTimer = 0.24
var dashMomentumTime = 0.3
var amtOfDashes = 1
var dashCounter = amtOfDashes
var dashDirection = Vector2.ZERO
var dashActive
var dashVelocity = Vector2.ZERO
var midAirDashLock = false
var waveDashMult = 0.5

var jumpInput = Input.is_action_just_pressed("jump")
var amtOfJumps = 1
var jumpCounter = amtOfJumps
var jumping = false
var jump_velocity = -450
var jumpBufferTime = 0.2
var jumpBufferCounter = jumpBufferTime
var coyoteDuration = 0.2
var coyoteTime = coyoteDuration

func gravity(delta):
	if not is_on_floor() and velocity.y < 100:
		velocity.y += gravityForce * delta
	else:
		velocity.y += gravityForce * 2 * delta

func handleDash(direction, delta):
	dashInput = Input.is_action_just_pressed("dash")
	if dashInput and not dashing and dashCounter > 0:
		print("dashed!")
		startDash(direction)
		coyoteTime = coyoteDuration + dashTimer
		if not is_on_floor():
			midAirDashLock = true
	if dashMomentumTime >= 0:
		dashMomentumTime -= delta
	updateDash(delta)
	if is_on_floor():
		dashCounter = amtOfDashes
	return dashMomentumTime > 0 
	
func startDash(direction):
	dashMomentumTime = 0.3
	dashDirection = direction.normalized()
	dashDuration = dashTimer
	dashing = true
	dashCounter -= 1

func updateDash(delta):
	storedMomentum = velocity
	if dashing:
		dashVelocity = (dashDirection * dashSpeed) 
		dashDuration -= delta
		if dashDuration <= 0:
			endDash(delta)
		elif dashDuration > 0:
			velocity = dashVelocity
		if is_on_floor() and dashDirection.y > 0:
			if jumping:
				storedMomentum.x += abs(velocity.x) * dashSpeed
				storedMomentum.x = min(storedMomentum.x, 4000)
				velocity.y = jump_velocity #immediate bounce if jump pressed
				velocity.x += storedMomentum.x
			else:
				velocity.y = -200 #small upward push from landinga
				dashing = false
				jumpCounter = amtOfJumps #allow jump right after
			
func endDash(delta):
	dashing = false
	if abs(dashDirection.x) > 0:
		velocity.x = dashDirection.x * maxSpeed
	else:
		velocity.x = 0
	if dashDirection.y < 0:
		velocity.y = lerp(velocity.y, gravityForce * 2 * delta, 0.3) 

func handleJump(delta):
	jumpInput = Input.is_action_just_pressed("jump")
	if jumpInput:
		jumpBufferCounter = jumpBufferTime
		
	if jumpBufferCounter > 0:
		jumpBufferCounter -= delta
		
	if jumpInput and jumpCounter > 0 and (is_on_floor() or coyoteTime >= 0) and !dashing and !midAirDashLock:
		startJump()
		jumpBufferCounter = 0
		
	if jumpBufferCounter > 0 and is_on_floor():
		startJump()
		jumpBufferCounter = 0
		
	if is_on_floor():
		midAirDashLock = false
		jumpCounter = amtOfJumps


func startJump():
	if is_on_floor():
		velocity.y = jump_velocity
		jumpCounter = amtOfJumps
	elif jumpCounter > 0:
		velocity.y = jump_velocity
		jumpCounter -= 1
	endJump()

func endJump():
	jumpCounter -= 1

func handleCoyoteTimer(delta):
	if is_on_floor():
		coyoteTime = coyoteDuration
	elif not is_on_floor():
		coyoteTime -= delta

func _physics_process(delta):
	horiDirection = Input.get_axis("left", "right")
	allDirection = Input.get_vector("left","right","lookUp","lookDown")
	targetVelocity = horiDirection * maxSpeed
	dashActive = handleDash(allDirection, delta)
	
	gravity(delta)
	handleCoyoteTimer(delta)
	handleJump(delta)
	
	if not dashActive: #if dash is NOT active
		if not dashing: #and you are not in the middle of dashing
			if horiDirection != 0: #and if your horizontal direction is NOT zero
				if sign(horiDirection) != sign(velocity.x) and velocity.x != 0: #AAND if the sign of your horizontal direction is different from your current x velocity, AND x velocity isnt 0
					velocity.x = move_toward(velocity.x, targetVelocity, friction * delta) #move toward the target velocity while applying friction
				else:
					velocity.x = move_toward(velocity.x, targetVelocity, acceleration * delta) #otherwise, just keep on accelerating
			else:
				velocity.x = move_toward(velocity.x, 0, friction * delta) #if no input, then friction kicks in
	
#	if Input.is_action_pressed("lookDown") and not is_on_floor():
#a		velocity.y += gravityForce * 3 * delta
	

#screen teleport logic 
	if position.x < 0:
		position.x = screenWidth - 15
	if position.x > screenWidth:
		position.x = 0
	
	print(velocity)
	move_and_slide()
