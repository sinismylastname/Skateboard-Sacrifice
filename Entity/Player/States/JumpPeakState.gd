extends PlayerState

func EnterState():
	Name = "JumpPeak"
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Player.handleJump()
	Player.ChangeState(States.Fall)
	
	
func handleAnimations():
	pass
