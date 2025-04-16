extends Node


@export var nav_agent: NavigationAgent2D
@onready var enemy : Enemy = get_owner()
@export var wander_radius: float = 100 # Radio to wander
var wander_destination = Vector2(0,0)
var speed_variation = 0.3
var is_chasing = false
var is_returning = false
var stopped = false
var target_node = null
var home_pos

func _ready():
	# Spawn position
	home_pos = enemy.global_position 


func _physics_process(delta: float) -> void:
	if stopped: return
	if nav_agent.is_navigation_finished():
		is_returning = false
		recalc_path()
		return
	
	var direction = enemy.to_local(nav_agent.get_next_path_position()).normalized()
	
	# Slow velocity when returning and wandering
	enemy.velocity = direction * (enemy.max_speed * (1 - speed_variation)) 
	
	if is_chasing:
		enemy.velocity = direction * enemy.max_speed
		
	enemy.move_and_collide(enemy.velocity * delta) 


func recalc_path():
	if target_node:
		nav_agent.target_position = target_node.global_position
	elif is_returning: 
		nav_agent.target_position = home_pos
	else:
		wander()

func wander():
	# In a boolean context, a Vector2 will evaluate to false if it's equal to Vector2(0, 0)
	if !wander_destination: 
		set_random_wander_target()

func set_random_wander_target():
	wander_destination = home_pos + Vector2(randi_range(-wander_radius, wander_radius), randi_range(-wander_radius, wander_radius))
	nav_agent.target_position = wander_destination


func _on_recalculate_timer_timeout() -> void:
	recalc_path()


func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target_node = body
		is_chasing = true
		is_returning= false
		wander_destination = Vector2(0,0)


func _on_de_aggro_range_body_exited(body: Node2D) -> void:
	if body == target_node:
		target_node = null
		is_chasing = false
		is_returning = true


func _on_navigation_agent_2d_navigation_finished() -> void:
	if !is_returning && !is_chasing:
		set_random_wander_target()

func stop():
	nav_agent.target_position = enemy.global_position
	enemy.velocity = Vector2.ZERO
	stopped = true
	is_returning = false
	is_chasing = false
