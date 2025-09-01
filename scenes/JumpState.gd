extends PlayerState

func EnterState():
	Name = "Jump"
	Player.velocity.y = Player.jumpPower
	print(Player.jumpCounter)
	
func ExitState():
	pass
	
func Update(delta: float):
	Player.handleHorizontalMovement()
	Player.handleJump()
	handleJumpToFall()
	handleAnimations()
	
func handleJumpToFall():
	if Player.velocity.y >= 0:
		Player.ChangeState(States.Fall)
	if (!Player.keyJump):
		Player.velocity.y *= Player.variableJumpMultiplier
		Player.ChangeState(States.Fall)
		
func handleAnimations():
	Player.Animator.play("jump")
	Player.handleFlipH()
	
