extends PlayerState

func EnterState():
	Name = "Run"
	Player.jumpCounter = Player.amtOfJumps

func ExitState():
	pass
	
func Update(delta: float):
	Player.handleHorizontalMovement()
	Player.handleJump()
	Player.handleFall()
	Player.handleDash()
	handleAnimations()
	handleIdle()

func handleIdle():
	if Player.xDirection == 0:
		Player.ChangeState(States.Idle)
		
func handleAnimations():
	Player.Animator.play("walk") #I really need to rename the animation 'Run' bruh wtf
	Player.handleFlipH()
