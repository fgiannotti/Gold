extends CharacterBody2D


const SPEED = 300
const run_speed = 600
func _process(_delta):
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * SPEED
	
	if Input.is_action_pressed("run"):  # Corremos con "shift"
		velocity = direction * run_speed

	move_and_slide()
