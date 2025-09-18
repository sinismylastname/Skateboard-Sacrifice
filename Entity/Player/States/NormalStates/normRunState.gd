extends PlayerState

func EnterState():
	Name = "Run"
	Machine.jumpCounter = Machine.amtOfJumps
	Machine.dashes = 0

func ExitState():
	#Machine.runningSound.stop()
	pass
	
func Update(delta: float):
	Machine.handleHorizontalMovement()
	Machine.handleJump()
	Machine.handleFall()
	Machine.handleDash()
	handleAnimations()
	handleIdle()

func handleIdle():
	if Machine.xDirection == 0:
		Machine.ChangeState(Machine.Idle)
		
func handleAnimations():
	Machine.Animator.play("walk") #I really need to rename the animation 'Run' bruh wtf
	Machine.handleFlipH() #actually in general i just need to make a RUN animation 
