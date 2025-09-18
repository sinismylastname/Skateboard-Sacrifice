extends PlayerState

func EnterState():
	Name = "Idle"
	Machine.jumpCounter = Machine.amtOfJumps
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Machine.handleFall()
	Machine.handleJump()
	Machine.handleHorizontalMovement()
	Machine.handleGravity(delta, Machine.gravityForceFall)
	if Machine.xDirection != 0:
		Machine.ChangeState(Machine.Run)
	HandleAnimations()
	
func HandleAnimations():
	Machine.Animator.play("idle")
	Machine.handleFlipH()
	
