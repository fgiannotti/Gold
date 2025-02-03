class_name EnemySpawner extends Node

var enemy_scene : PackedScene = preload("res://enemy/enemy.tscn")

var enemy_stats: Array[EnemyData] = [
	preload("res://enemy/enemy_data_slime_green.tres"),
	preload("res://enemy/enemy_data_slime_brown.tres")
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Positions from the tilemapLayer and how many enemies
func spawn_enemies(valid_positions: Array, qty: int):
	for n in qty:
		var spawned_enemy : Enemy = enemy_scene.instantiate()
		spawned_enemy.stats = enemy_stats[1]
		get_parent().add_child.call_deferred(spawned_enemy)
		var aux_positon = valid_positions.pick_random()
		spawned_enemy.global_position = aux_positon
		
