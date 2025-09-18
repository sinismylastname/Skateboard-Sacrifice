extends PlayerState

func EnterState():
	Name = "Jump"
	Machine.velocity.y = Machine.jumpPower
	#Machine.jumpSound.play()
	
	if Machine.canUseDashMomentum:
		var dir = 1 if Machine.keyRight else -1 if Machine.keyLeft else 0
		Machine.velocity.x += dir * Machine.storedDashMomentum
		Machine.storedDashMomentum = 0
		Machine.canUseDashMomentum = false
	
func ExitState():
	pass

func Update(delta: float):
	Machine.handleHorizontalMovement()
	Machine.handleGravity(delta, Machine.gravityForceFall)
	Machine.handleJump()
	Machine.handleTricks()
	handleJumpToFall()
	handleAnimations()
	
func handleJumpToFall():
	if Machine.velocity.y >= 0:
		Machine.ChangeState(Machine.Fall)
	if (!Machine.keyJump):
		Machine.velocity.y *= Machine.variableJumpMultiplier
		Machine.ChangeState(Machine.Fall)
		
func handleAnimations():
	Machine.Animator.play("jump")
	Machine.handleFlipH()
	
	#dude lowkey what am i doing. bro DEADASS im stupid as fuck. holy moly HOLY MOLY!!!! IM GARBAGE wooow okay im going to kms
	#like deadass bro what is this.
