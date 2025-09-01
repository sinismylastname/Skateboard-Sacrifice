extends PlayerState

func EnterState():
	Name = "Fall"
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Player.handleGravity(delta, Player.gravityForceFall)
	Player.handleHorizontalMovement()
	Player.handleJump()
	Player.handleJumpBuffer()
	Player.handleLanding()
	handleAnimations()
	
func handleAnimations():
	Player.Animator.play("fall")
	Player.handleFlipH
