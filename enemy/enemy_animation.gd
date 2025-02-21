extends Node

@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D
@export var nav_agent: NavigationAgent2D
@onready var enemy : Enemy = get_owner()

var player: Player
var detection_radius: float = 10

var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
var current_direction = Vector2.ZERO
var is_chasing = false
var is_returning = false
var target_node = null
var home_pos

func _ready():
	player = get_node("../../Player")
	change_direction()
	home_pos = enemy.global_position
	
	$Timer.wait_time = 2.0
	$Timer.start()

func _physics_process(delta: float) -> void:
	
	var direction_to_player = (player.global_position - enemy.global_position).normalized()
	var distance_to_player = enemy.global_position.distance_to(player.global_position)
	
	if nav_agent.is_navigation_finished():
		is_returning = false
		return
	
	var axis = enemy.to_local(nav_agent.get_next_path_position()).normalized()
	enemy.velocity = axis * enemy.max_speed
	
	#cambio de sprite png para correr o caminar

	enemy.move_and_collide(enemy.velocity * delta)  #Entender linea
	

	update_animation()

func change_direction():
	if not is_chasing:
		current_direction = directions[randi_range(0,directions.size()-1)]

func recalc_path():
	if target_node:
		nav_agent.target_position = target_node.global_position
	elif is_returning: 
		nav_agent.target_position = home_pos
	else:
		wander()

func wander():
	pass

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

func _on_Timer_timeout():
	change_direction()


func _on_recalculate_timer_timeout() -> void:
	recalc_path()


func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target_node = body
		is_chasing = true
		sprite.texture = enemy.enemy_data.run_sprite


func _on_de_aggro_range_body_exited(body: Node2D) -> void:
	if body == target_node:
		target_node = null
		is_chasing = false
		is_returning= true
		sprite.texture = enemy.enemy_data.walk_sprite
