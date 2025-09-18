extends PlayerState

const dashSquish = 0.25
var distortionEffect = preload("res://scenes/DashDistortion.tscn")

func EnterState():
	Name = "Dash"
	Machine.dashDirection = Machine.getDashDirection()
	Machine.dashGhost.restart()
	Machine.velocity = Machine.dashDirection.normalized() * Machine.dashSpeed
	Machine.dashTimer.start(Machine.dashTime)
	Machine.setSquish(abs(Machine.dashDirection.y * dashSquish), abs(Machine.dashDirection.x * dashSquish))
	var _distortion = distortionEffect.instantiate()
	_distortion.global_position = Player.global_position
	get_tree().root.get_node("World").add_child(_distortion)
	Machine.Animator.play("dash")
	Machine.handleFlipH()
	
func ExitState():
	pass
	
func Update(delta: float):
	handleDashCollide()
	handleDashEnd()
	handleAnimations()
	
func handleDashEnd():
	if Machine.dashTimer.time_left <= 0 or Player.is_on_floor():
		Machine.dashTimer.stop()
		
		if Player.is_on_floor():
			var momentumGain = abs(Machine.dashDirection.x * Machine.dashSpeed)
			Machine.storedDashMomentum += momentumGain * (1 - min(Machine.storedDashMomentum / Machine.maxStoredMomentum, 1)) / 2
			Machine.canUseDashMomentum = true
			Machine.dashes = 0
			Machine.ChangeState(Machine.Run)
		else:
			Machine.velocity.x *= Machine.dashMomentumCarry
			Machine.ChangeState(Machine.Fall)

func handleDashCollide():
	if Player.is_on_wall():
		Machine.dashTimer.stop()
		Machine.velocity += -2 * Machine.velocity
	if Machine.velocity.y > 0 and Player.is_on_floor():
		Machine.dashTimer.stop()

func handleAnimations():
	Machine.Animator.play("dash")
	Machine.handleFlipH()
	
