extends PlayerState

func EnterState():
	Name = "Jump"
	Player.velocity.y = Player.jumpPower
	Player.jumpSound.play()
	
	if Player.canUseDashMomentum:
		var dir = 1 if Player.keyRight else -1 if Player.keyLeft else 0
		Player.velocity.x += dir * Player.storedDashMomentum
		Player.storedDashMomentum = 0
		Player.canUseDashMomentum = false
	
func ExitState():
	Player.bunnyHopTimer.start(Player.bhTime)
	pass

func Update(delta: float):
	Player.handleHorizontalMovement()
	Player.handleGravity(delta, Player.gravityForceFall)
	Player.handleJump()
	Player.handleDash()
	handleJumpToFall()
	handleAnimations()
	
func handleJumpToFall():
	if Player.velocity.y >= 0:
		Player.ChangeState(States.Fall)
	if (!Player.keyJump):
		Player.velocity.y *= Player.variableJumpMultiplier
		Player.ChangeState(States.Fall)
		
func handleAnimations():
	Player.Animator.play("jump")
	Player.handleFlipH()
	
