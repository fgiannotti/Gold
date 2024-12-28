extends CharacterBody2D

signal food_updated(value: float)

const SPEED = 180
const run_speed = 280
var food: float
const STEPS_FOR_HUNGER = 100
var step_count = 0

const moving = false

func _process(delta):
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * SPEED
	
	if Input.is_action_pressed("run"):  # Corremos con "shift"
		velocity = direction * run_speed
	
	
	var collision_info = move_and_collide(velocity * delta)
	if !collision_info and (direction.x != 0 || direction.y != 0):
		print('[player] step count++ ', step_count, ' ',food)
		step_count += 1
		if step_count >= STEPS_FOR_HUNGER:
			step_count = 0
			food -= 1
			emit_signal("food_updated", food)

func _ready():
	food = 100
	
