extends CharacterBody2D


const SPEED = 300

func _process(_delta):
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * SPEED

	move_and_slide()
