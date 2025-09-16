extends PlayerState

func EnterState():
	Name = "Idle"
	Player.jumpCounter = Player.amtOfJumps
	Player.dashes = 0
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Player.handleFall()
	Player.handleJump()
	Player.handleHorizontalMovement()
	Player.handleDash()
	Player.handleGravity(delta, Player.gravityForceFall)
	if Player.xDirection != 0:
		Player.ChangeState(States.Run)
	HandleAnimations()
	
func HandleAnimations():
	Player.Animator.play("idle")
	Player.handleFlipH()
