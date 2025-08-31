extends PlayerState

func EnterState():
	Name = "Run"

func ExitState():
	pass
	
func Update(delta: float):
	Player.handleHorizontalMovement()
	Player.handleJump()
	Player.handleFall()
	handleAnimations()
	handleIdle()

func handleIdle():
	if Player.xDirection == 0:
		Player.ChangeState(States.Idle)
		
func handleAnimations():
	Player.Animator.play("walk") #I really need to rename the animation 'Run' bruh wtf
	Player.handleFlipH()
