extends PlayerState

func EnterState():
	Name = "Idle"
	Player.jumpCounter = Player.amtOfJumps
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Player.handleFall()
	Player.handleJump()
	Player.handleHorizontalMovement()
	Player.handleDash()
	if Player.xDirection != 0:
		Player.ChangeState(States.Run)
	HandleAnimations()
	
func HandleAnimations():
	Player.Animator.play("idle")
	Player.handleFlipH()
