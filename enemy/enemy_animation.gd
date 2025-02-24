extends Node


@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D
@export var nav_agent: NavigationAgent2D
@onready var enemy : Enemy = get_owner()
@export var wander_radius: float = 100 # Radio to wander
var player: Player
var wander_destination = Vector2(0,0)
var speed_variation = 0.3
var is_chasing = false
var is_returning = false
var target_node = null
var home_pos

func _ready():
	player = get_node("../../Player")
	home_pos = enemy.global_position #Spawn position
	
	$Timer.wait_time = 2.0
	$Timer.start()

func _physics_process(delta: float) -> void:
	
	if nav_agent.is_navigation_finished():
		is_returning = false
		recalc_path()
		return
	
	var axis = enemy.to_local(nav_agent.get_next_path_position()).normalized()
	if is_chasing:
			enemy.velocity = axis * enemy.max_speed
	else: enemy.velocity = axis * (enemy.max_speed * (1 - speed_variation)) #Slow velocity in returning and wandering
		
	
	enemy.move_and_collide(enemy.velocity * delta) 
	update_animation()


func recalc_path():
	if target_node:
		nav_agent.target_position = target_node.global_position
	elif is_returning: 
		nav_agent.target_position = home_pos
	else:
		wander()

func wander():
	if !wander_destination: #In a boolean context, a Vector2 will evaluate to false if it's equal to Vector2(0, 0)
		set_random_wander_target()

func set_random_wander_target():
	wander_destination = home_pos + Vector2(randi_range(-wander_radius, wander_radius), randi_range(-wander_radius, wander_radius))
	nav_agent.target_position = wander_destination

func update_animation():
	
	var velocity = enemy.velocity
	var direction = Vector2.ZERO
	
	if velocity.length() > 0:
		direction = velocity.normalized()
	
	if direction.x > 0 and abs(direction.x) > abs(direction.y):
		animation_player.play("walkRight")
	elif direction.x < 0 and abs(direction.x) > abs(direction.y):
		animation_player.play("walkLeft")
	elif enemy.velocity.y > 0:
		animation_player.play("walkDown")
	elif enemy.velocity.y < 0:
		animation_player.play("walkUp")



func _on_recalculate_timer_timeout() -> void:
	recalc_path()


func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target_node = body
		is_chasing = true
		is_returning= false
		wander_destination = Vector2(0,0)
		sprite.texture = enemy.enemy_data.run_sprite


func _on_de_aggro_range_body_exited(body: Node2D) -> void:
	if body == target_node:
		target_node = null
		is_chasing = false
		is_returning= true
		sprite.texture = enemy.enemy_data.walk_sprite



func _on_navigation_agent_2d_navigation_finished() -> void:
	if !is_returning && !is_chasing:
		set_random_wander_target()
