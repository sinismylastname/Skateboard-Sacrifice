extends PlayerState

func EnterState():
	Name = "Fall"
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Machine.handleGravity(delta, Machine.gravityForceFall)
	Machine.handleHorizontalMovement()
	Machine.handleJump()
	Machine.handleDash()
	Machine.handleJumpBuffer()
	Machine.handleLanding()
	handleAnimations()
	
func handleAnimations():
	Machine.Animator.play("fall")
	Machine.handleFlipH()
