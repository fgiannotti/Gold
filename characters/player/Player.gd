extends CharacterBody2D

class_name Player

const SPEED = PlayerManager.PLAYER_SPEED

const run_speed = 1000
const STEPS_FOR_HUNGER = PlayerManager.STEPS_FOR_HUNGER
var step_count = 0

const moving = false
var is_immune = false
var is_attacking = false
var is_interacting: bool = false
@onready var use_cooldown = $UseCooldown
@onready var animations = $AnimationPlayer
@onready var immunity_cooldown = $InmunityCooldown

@export var collectablesLayer: TileMapLayer

var facing_direction: Vector2 # Saves last moved direction


func _ready():
	pass

func _process(delta):
	var direction = process_direction()

	self.velocity = direction * SPEED

	var movement_collides = null
	if !is_interacting:
		movement_collides = move_and_collide(self.velocity * delta)
	
	if Input.is_action_pressed("run"): # Corremos con "shift"
		self.velocity = direction * run_speed


	if Input.is_action_just_pressed("attack") and !is_interacting and !is_attacking:
		is_attacking = true
		play_attack_animation()
		await animations.animation_finished
		is_attacking = false
		return

	if Input.is_action_pressed("mine"):
		is_interacting = true
		
		play_mine_animation()
		var world_position = nearest_world_tile()
		var collectable: Node2D = collectablesLayer.mineral_at_world_pos(world_position)
		print('trying to mine nearest tile: ', world_position, 'collectable ', collectable)
		if world_position && collectable && collectable.is_in_group("minerals"):
			if player_facing_mineral(collectable):
				collectablesLayer.mine_tile(world_position)
			else:
				print("[Player] Not facing mineral, abort collect")
		await animations.animation_finished
		# use_cooldown.start() not working properly
		is_interacting = false
		return

	if Input.is_action_just_pressed("use") && !is_interacting:
		is_interacting = true
		
		play_use_animation()
		var world_position = nearest_world_tile()
		print('[Player] trying to interact nearest tile: ', world_position)
		var collectable: Node2D = collectablesLayer.collectable_at_world_pos(world_position)
		# Code can collect, move all into collectable. Objective]: improve use action
		print('[Player] got collectable: ', collectable)
		if world_position && collectable && collectable.has_method("collect") && !collectable.is_in_group("minerals"):
			collectablesLayer.collect_tile(world_position)
		await animations.animation_finished
		is_interacting = false
		#use_cooldown.start()
		return

	if Input.is_action_just_pressed("talk") && !is_interacting:
		play_use_animation()
		print('[Player] trying to talk FIRST HIT')
		InteractionManager.start_interaction()
		await animations.animation_finished
	
	var movement_intent_exists: bool = direction.x != 0 || direction.y != 0
	trigger_hunger(movement_collides, movement_intent_exists)

	if !is_interacting && !is_attacking:
		if direction != Vector2(0, 0):
			if is_immune:
				play_hurt_movement_animation()
			else:
				play_movement_animation()
		else:
			if !is_immune: # so that hurt animation plays
				play_idle_animation()

'''# values set from binary mapping
const SOUTH_POS = 0
const EAST_POS  = 1
const NORTH_POS = 2
const WEST_POS  = 3'''
func player_facing_mineral(mineral: Mineral):
	var direction = self.direction_string(facing_direction)
	if mineral.is_in_group("minerals_0") && direction == "Down":
		return true
	if mineral.is_in_group("minerals_1") && direction == "Right":
		return true
	if mineral.is_in_group("minerals_2") && direction == "Up":
		return true
	if mineral.is_in_group("minerals_3") && direction == "Left":
		return true
	print("[Player] Player direction is " + direction + " But mineral groups are: " + str(mineral.get_groups()))
	return false

func nearest_world_tile() -> Vector2:
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
	
func play_idle_animation():
	animations.play("idle" + direction_string(self.facing_direction))
	
func play_hurt_movement_animation():
	animations.play("walkHurt" + direction_string(self.facing_direction))

func play_mine_animation():
	animations.play("mine" + direction_string(self.facing_direction))

func play_use_animation():
	animations.play("use" + direction_string(self.facing_direction))

func play_hit_animation():
	print("playing hit"+ direction_string(self.facing_direction))
	animations.play("hit" + direction_string(self.facing_direction))

func play_attack_animation():
	animations.play("attack"+ direction_string(self.facing_direction))
	
# movement_collides is null when there was no collision
func trigger_hunger(movement_collides: KinematicCollision2D, movement_intent_exists: bool):
	if !movement_collides and movement_intent_exists and !is_interacting:
		# print('[player] step count++ ', step_count, ' ',food)
		step_count += 1
		if step_count >= STEPS_FOR_HUNGER:
			step_count = 0
			PlayerManager.set_food(PlayerManager.food-1)

func direction_string(direction: Vector2):
	if direction == Vector2.LEFT:
		return "Left"
	elif direction == Vector2.RIGHT:
		return "Right"
	elif direction == Vector2.UP:
		return "Up"
	elif direction == Vector2.DOWN:
		return "Down"

	return "Down"

func receive_damage(dmg: float):
	if !is_immune:
		PlayerManager.set_health(PlayerManager.health - dmg)
		print("Player recieved damage: ", dmg, " HP: ", PlayerManager.health)
		play_hit_animation()
		
		# Reset interactions or attacks if damaged
		is_interacting = false
		is_attacking = false
		
		immunity_cooldown.start()
		is_immune = true

func _on_inmunity_cooldown_timeout() -> void:
	is_immune = false

func _on_use_cooldown_timeout() -> void:
	is_interacting = false

func _on_weapon_area_area_entered(area: Area2D) -> void:
	print("[Player] Weapon touched something....")
	if area is HurtBox:
		print("[Player] Sending damage....")
		area.take_damage(self.velocity, 50) 


func _on_visibility_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print('[Player] setting body visible to true ', body)
		body.visible = true


func _on_visibility_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print('[Player] setting body visible to true ', body)
		body.visible = false
