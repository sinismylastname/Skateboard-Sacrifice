extends PlayerState

func EnterState():
	Name = "Idle"
	Machine.jumpCounter = Machine.amtOfJumps
	Machine.dashes = 0
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Machine.handleFall()
	Machine.handleJump()
	Machine.handleHorizontalMovement()
	Machine.handleDash()
	Machine.handleGravity(delta, Machine.gravityForceFall)
	if Machine.xDirection != 0:
		Machine.ChangeState(Machine.Run)
	HandleAnimations()
	
func HandleAnimations():
	Machine.Animator.play("idle")
	Machine.handleFlipH()
	
# i am going to DIE. i have refactored all this code about 4-5 times now... the day i reach
# 6 - 7 times, it's over for everyone.
