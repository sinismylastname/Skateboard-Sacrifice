extends PlayerState

func EnterState():
	Name = "Jump"
	Player.velocity.y = Player.jumpPower
	Player.jumpCounter -= 1
	print(Player.jumpCounter)
	
func ExitState():
	pass
	
func Update(delta: float):
	Player.handleHorizontalMovement()
	handleJumpToFall()
	handleAnimations()
	
func handleJumpToFall():
	if Player.velocity.y >= 0:
		Player.ChangeState(States.JumpPeak)
		
func handleAnimations():
	Player.Animator.play("jump")
	Player.handleFlipH()
	
