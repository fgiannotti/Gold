extends CharacterBody2D

signal food_updated(value: float)

const SPEED = 180

const run_speed = 1000
var food: float
const STEPS_FOR_HUNGER = 100
var step_count = 0

const moving = false

@onready var animations = $AnimationPlayer

func _process(delta):
	var direction = Input.get_vector("left","right","up","down")
	self.velocity = direction * SPEED

	var collision_info = move_and_collide(self.velocity * delta)
	
	if Input.is_action_pressed("run"):  # Corremos con "shift"
		velocity = direction * run_speed

	if !collision_info and (direction.x != 0 || direction.y != 0):
		#print('[player] step count++ ', step_count, ' ',food)
		step_count += 1
		if step_count >= STEPS_FOR_HUNGER:
			step_count = 0
			food -= 1
			emit_signal("food_updated", food)
	if direction != Vector2(0,0):
		play_movement_animation()
	else:
		animations.stop(true)

func play_movement_animation():
	var direction = "Down"
	if self.velocity.x < 0: direction = "Left"
	elif self.velocity.x > 0: direction = "Right"
	elif self.velocity.y < 0: direction = "Up"
	animations.play("walk" + direction)
	#print("Player position: ", self.position)

func _ready():
	food = 100
	
