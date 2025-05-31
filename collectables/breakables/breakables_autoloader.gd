extends Node

################################################
# This is an autoloaded node to spawn breakable interactables
################################################
@onready var walls_tilemap
@onready var collectables_tilemap

var breakable_interactable_scene: PackedScene = preload("res://collectables/breakables/breakable_interactable.tscn")
var box_config: BreakableConfig = preload("res://collectables/breakables/configs/box_config.tres")

const TARGET_BREAKABLE_COUNT = 40
var rng = RandomNumberGenerator.new()

func respawn_breakables():
	clear_breakables()
	spawn_all_breakables()
	
func clear_breakables():
	get_tree().call_group("breakables", "queue_free")
	
func spawn_all_breakables():
	print('[BreakablesAutoloader] Spawning ', TARGET_BREAKABLE_COUNT, ' breakables in rooms...')
	
	if not walls_tilemap or not walls_tilemap.rooms or walls_tilemap.rooms.size() == 0:
		print('[BreakablesAutoloader] No rooms found, cannot spawn breakables')
		return
	
	var breakables_spawned = 0
	var max_attempts = TARGET_BREAKABLE_COUNT * 5  # Increased attempts due to more collision checks
	var attempt_count = 0
	
	while breakables_spawned < TARGET_BREAKABLE_COUNT and attempt_count < max_attempts:
		attempt_count += 1
		
		# Get a random room position
		var room_position = get_random_room_position()
		if room_position == Vector2.ZERO:
			continue
		
		# Check if this position is valid (no collisions)
		if not is_position_valid(room_position):
			continue
		
		# Convert to tilemap coordinates and spawn
		var tilemap_coords = walls_tilemap.local_to_map(room_position)
		if spawn_breakable_at_position(tilemap_coords):
			breakables_spawned += 1
			
	print('[BreakablesAutoloader] Successfully spawned ', breakables_spawned, ' breakables out of ', TARGET_BREAKABLE_COUNT, ' target')

func get_random_room_position() -> Vector2:
	# Use the existing room system from walls_tilemap
	if not walls_tilemap or not walls_tilemap.has_method("get_random_room_pos_to_global"):
		print('[BreakablesAutoloader] walls_tilemap missing get_random_room_pos_to_global method')
		return Vector2.ZERO
	
	# Get a random position from the open room positions
	return walls_tilemap.get_random_room_pos_to_global()

func spawn_breakable_at_position(tilemap_coords: Vector2i) -> bool:
	var breakable_instance = breakable_interactable_scene.instantiate()
	
	# Apply the box configuration
	breakable_instance.config = box_config
	
	# Add to breakables group for easy cleanup
	breakable_instance.add_to_group("breakables", true)
	
	# Spawn using the collectables tilemap system
	collectables_tilemap.spawn_scene_at_tile(tilemap_coords, breakable_instance)
	
	print('[BreakablesAutoloader] Spawned breakable at tilemap coords: ', tilemap_coords)
	return true 

func is_position_valid(world_position: Vector2) -> bool:
	# Check for existing collectables (minerals, chests, etc.)
	var existing_collectable = collectables_tilemap.collectable_at_world_pos(world_position)
	if existing_collectable:
		print('[BreakablesAutoloader] Position occupied by collectable: ', existing_collectable.name)
		return false
	
	# Check for existing breakables
	var existing_breakable = get_existing_breakable_at_position(world_position)
	if existing_breakable:
		print('[BreakablesAutoloader] Position occupied by existing breakable')
		return false
	
	# Check for ladder/stair position
	if is_position_near_ladder(world_position):
		print('[BreakablesAutoloader] Position too close to ladder')
		return false
	
	# Check for other important interactables (forge, muki, etc.)
	if is_position_near_important_objects(world_position):
		print('[BreakablesAutoloader] Position too close to important objects')
		return false
	
	return true

func get_existing_breakable_at_position(world_position: Vector2) -> Node2D:
	# Check if there's already a breakable at this position
	var breakables = get_tree().get_nodes_in_group("breakables")
	var position_tolerance = 32.0  # Same as in collectables_tilemap
	
	for breakable in breakables:
		if breakable is Node2D and breakable.global_position.distance_to(world_position) < position_tolerance:
			return breakable
	
	return null

func is_position_near_ladder(world_position: Vector2) -> bool:
	# Check if position is too close to the ladder/stair
	var ladder_areas = get_tree().get_nodes_in_group("travel_areas")
	var safe_distance = 64.0  # Give some space around the ladder
	
	for area in ladder_areas:
		if area is Node2D and area.global_position.distance_to(world_position) < safe_distance:
			return true
	
	return false

func is_position_near_important_objects(world_position: Vector2) -> bool:
	var safe_distance = 48.0  # Safe distance from important objects
	
	# Check for forge
	var forges = get_tree().get_nodes_in_group("forges")
	for forge in forges:
		if forge is Node2D and forge.global_position.distance_to(world_position) < safe_distance:
			return true
	
	# Check for Muki (directly by name since it doesn't have a specific group)
	var world_node = get_tree().get_first_node_in_group("world")
	if not world_node:
		world_node = get_tree().current_scene
	
	var muki_node = world_node.get_node_or_null("Muki")
	if muki_node and muki_node is Node2D:
		if muki_node.global_position.distance_to(world_position) < safe_distance:
			return true
	
	var player = world_node.get_node_or_null("Player")
	if player and player is Node2D:
		# Only check at the start when player hasn't moved much
		var initial_spawn_area = Vector2(144, 81)  # From the world.tscn
		if world_position.distance_to(initial_spawn_area) < safe_distance:
			return true
	
	return false 
