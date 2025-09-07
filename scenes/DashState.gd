extends PlayerState

const dashSquish = 0.25
var distortionEffect = preload("res://scenes/DashDistortion.tscn")

func EnterState():
	Name = "Dash"
	Player.dashDirection = Player.getDashDirection()
	Player.dashGhost.restart()
	Player.velocity = Player.dashDirection.normalized() * Player.dashSpeed
	Player.dashTimer.start(Player.dashTime)
	Player.setSquish(abs(Player.dashDirection.y * dashSquish), abs(Player.dashDirection.x * dashSquish))
	var _distortion = distortionEffect.instantiate()
	_distortion.global_position = Player.global_position
	get_tree().root.get_node("World").add_child(_distortion)
	Player.Animator.play("dash")
	Player.handleFlipH()
	
func ExitState():
	pass
	
func Update(delta: float):
	handleDashEnd()
	handleAnimations()
		
func handleDashEnd():
	if Player.dashTimer.time_left <= 0:
		Player.dashTimer.stop()
		Player.velocity *= Player.dashMomentumCarry
		Player.ChangeState(States.Fall)

func handleAnimations():
	Player.Animator.play("dash")
	Player.handleFlipH()
	
