extends PlayerState

func EnterState():
	Name = "JumpPeak"
	
func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	Machine.handleJump()
	Machine.ChangeState(Machine.Fall)
	
	
func handleAnimations():
	pass
