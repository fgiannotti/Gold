extends Node

var enemy_scene : PackedScene = preload("res://enemy/enemy.tscn")

var enemy_stats: Array[EnemyData] = [
	preload("res://enemy/enemy_data_slime_green.tres"),
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_enemy(stats: EnemyData):
	var spawned_enemy : Enemy = enemy_scene.instantiate()
	spawned_enemy.stats = stats
	get_tree().root.add_child(spawned_enemy)
	spawned_enemy.global_position = Vector2(200,200)
