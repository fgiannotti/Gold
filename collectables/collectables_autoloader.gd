extends Node

@onready var collectables_tilemap
@onready var walls_tilemap

var chest: PackedScene = preload("res://collectables/chest.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func respawn_collectables():
	clear_collectables()
	spawn_all_collectables()

func clear_collectables():
	get_tree().call_group("chests", "queue_free")

func spawn_all_collectables():
	# spawn them sequentially with a random. Then ask gpt how to do it better
	for x in range(1, walls_tilemap.MAZE_WIDTH):
		for y in range(1, walls_tilemap.MAZE_HEIGHT):
			if RandomNumberGenerator.new().randi_range(1,100) > 96:
				var directions = walls_tilemap.directions_closed_at_pos(Vector2i(x,y))
				if directions == [1,1,1,1]:
					continue
				var valid_pos = rng_until_valid_pos(directions)
				spawn_chest_at_pos(Vector2i(x,y), valid_pos)

# SENW
# valid pos is one of 0 to 3 for SENW
func spawn_chest_at_pos(coords: Vector2i, valid_pos: int):
	# Check if this position would collide with existing interactables
	var world_position = collectables_tilemap.map_to_local(coords)
	if PlacementManager.is_position_occupied(world_position):
		print('[CollectableAutoloader] Skipping chest spawn at %s - position occupied' % [world_position])
		return
	
	var chest_instance: Node = chest.instantiate()
	set_facing_sprite(chest_instance, valid_pos)
	chest_instance.add_to_group("chests", true)
	# print('mineral data: ', mineral_instance.mineral_data.resource_name)
	collectables_tilemap.spawn_scene_at_tile(coords, chest_instance)
	
	# Mark position as occupied in PlacementManager
	PlacementManager.mark_position_occupied(world_position)
	print('[CollectableAutoloader] Spawned chest at %s' % [world_position])
	return

func set_facing_sprite(chest,valid_pos):
	if valid_pos == 0: # S
		chest.facing_down()
	elif valid_pos == 1: # E
		chest.facing_left()
	elif valid_pos == 2: # N
		chest.facing_up()
	elif valid_pos == 3: # W
		chest.facing_right()

# look for closed open to put chest
func rng_until_valid_pos(directions: Array[int]) -> int:
	while true:
		var position = randi_range(0,3)
		if directions[position] == 0:
			return position
	return -1
