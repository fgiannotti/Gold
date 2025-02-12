extends CharacterBody2D

class_name Player
signal food_updated(value: float)

const SPEED = 180

const run_speed = 1000
var hp := 20.0
var food: float
const STEPS_FOR_HUNGER = 100
var step_count = 0

const moving = false
var is_mining = false
var is_immune = false
@onready var animations = $AnimationPlayer
@onready var immunity_cooldown = $Timer

@export var collectablesLayer: TileMapLayer

var facing_direction: Vector2 # Saves last moved direction

func _process(delta):
	var direction = process_direction()

	self.velocity = direction * SPEED

	var movement_collides = null
	if !is_mining:
		movement_collides = move_and_collide(self.velocity * delta)
	
	if Input.is_action_pressed("run"):  # Corremos con "shift"
		self.velocity = direction * run_speed

	if Input.is_action_pressed("mine"):
		is_mining = true
		
		play_mine_animation()
		var tile_position = nearest_tile()
		print('trying to mine nearest tile: ', tile_position, ' player position: ',  self.position)
		if tile_position:
			collectablesLayer.mine_tile(tile_position)
		await animations.animation_finished
		is_mining = false
		return
		
	var movement_intent_exists: bool = direction.x != 0 || direction.y != 0
	trigger_hunger(movement_collides, movement_intent_exists)

	if !is_mining:
		if direction != Vector2(0,0):
			play_movement_animation()
		else:
			animations.stop(true)

func nearest_tile() -> Vector2:
	var player_position = position
	return (player_position + facing_direction).floor()

func process_direction():
	if Input.is_action_pressed("left"):
		facing_direction = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		facing_direction = Vector2.RIGHT
	elif Input.is_action_pressed("up"):
		facing_direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		facing_direction = Vector2.DOWN
	else: 
		return Vector2.ZERO

	return facing_direction

func play_movement_animation():
	animations.play("walk" + direction_string(self.facing_direction))

func play_mine_animation():
	animations.play("mine" + direction_string(self.facing_direction))

func _ready():
	food = 100
	print("player is at ", self.global_position)

# movement_collides is null when there was no collision
func trigger_hunger(movement_collides: KinematicCollision2D, movement_intent_exists: bool):
	if !movement_collides and movement_intent_exists and !is_mining:
		# print('[player] step count++ ', step_count, ' ',food)
		step_count += 1
		if step_count >= STEPS_FOR_HUNGER:
			step_count = 0
			food -= 1
			emit_signal("food_updated", food)

func direction_string(direction: Vector2):
	if direction == Vector2.LEFT:
		return "Left"
	elif direction == Vector2.RIGHT:
		return "Right"
	elif direction == Vector2.UP:
		return "Up"
	elif direction == Vector2.DOWN:
		return "Down"

func receive_damage(dmg: float):
	if dmg < self.hp && !is_immune:
		self.hp -= dmg
		print("Player recieved damage: ", dmg, " HP: ", hp)
		immunity_cooldown.start()
		is_immune = true
	elif dmg > self.hp:
		print("Dead X(")
	

func _on_timer_timeout() -> void:
	is_immune = false
