extends Node

@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D
@onready var enemy : Enemy = get_owner()

var player: Player
var detection_radius: float = 100

var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
var current_direction = Vector2.ZERO
var is_chasing = false

func _ready():
	player = get_node("../../Player")
	change_direction()
	$Timer.wait_time = 2.0
	$Timer.start()

func _physics_process(delta: float) -> void:
	var direction_to_player = (player.global_position - enemy.global_position).normalized()
	var distance_to_player = enemy.global_position.distance_to(player.global_position)
	
	if distance_to_player < detection_radius:
		enemy.velocity = direction_to_player * enemy.max_speed
		is_chasing = true
		sprite.texture = enemy.enemy_data.run_sprite
	else:
		enemy.velocity = current_direction * (enemy.max_speed/2)
		is_chasing = false
		sprite.texture = enemy.enemy_data.walk_sprite

	var collision = enemy.move_and_collide(enemy.velocity * delta)
	
	if collision:
		change_direction()

	update_animation()

func change_direction():
	if not is_chasing:
		current_direction = directions[randi_range(0,directions.size()-1)]


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
