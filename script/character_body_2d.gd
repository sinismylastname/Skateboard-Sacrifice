extends CharacterBody2D

var speed = 400
var jump_velocity = -500 
const gravity = 980


func _physics_process(delta):
	velocity.y += gravity * delta

	var input_direction = Input.get_axis("left", "right")
	velocity.x = input_direction * speed

	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		print("jumped!")
	if Input.is_action_just_pressed("dash"):
		print("dashed!")
		pass
	move_and_slide()
