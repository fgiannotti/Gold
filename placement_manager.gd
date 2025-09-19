extends Node

################################################
# Global Placement Manager - Prevents interactable collisions
################################################

# Centralized system to track occupied positions
var occupied_positions: Array[Vector2] = []
var POSITION_TOLERANCE = 16.0  # Half a tile size for tolerance

# Reference to the collectables tilemap for collision checking
var collectables_tilemap: TileMapLayer

func initialize(tilemap: TileMapLayer):
	collectables_tilemap = tilemap
	clear_occupied_positions()

func clear_occupied_positions():
	occupied_positions.clear()
	print("[PlacementManager] Cleared all occupied positions")

# Check if a world position is occupied by any interactable
func is_position_occupied(world_pos: Vector2) -> bool:
	# Check our tracked occupied positions
	for occupied_pos in occupied_positions:
		if world_pos.distance_to(occupied_pos) < POSITION_TOLERANCE:
			return true
	
	# Also check existing collectables in the scene
	if collectables_tilemap:
		var collectable = collectables_tilemap.collectable_at_world_pos(world_pos)
		if collectable:
			return true
	
	return false

# Mark a position as occupied
func mark_position_occupied(world_pos: Vector2):
	occupied_positions.append(world_pos)
	print("[PlacementManager] Marked position as occupied: " + str(world_pos))

# Initialize occupied positions by scanning existing collectables
func scan_existing_collectables():
	if not collectables_tilemap:
		print("[PlacementManager] No collectables tilemap set")
		return
		
	print("[PlacementManager] Scanning existing collectables...")
	
	# Scan all existing collectables and mark their positions as occupied
	for child in collectables_tilemap.get_children():
		if child is Node2D:
			mark_position_occupied(child.global_position)
			print("[PlacementManager] Found existing collectable: " + child.name + " at " + str(child.global_position))

# Get all available positions in rooms, excluding occupied ones
func get_available_room_positions(walls_tilemap) -> Array:
	var available_positions = []
	
	if not walls_tilemap or not walls_tilemap.positions_open_room:
		print("[PlacementManager] No walls_tilemap or positions_open_room")
		return available_positions
	
	print("[PlacementManager] Checking %d room positions against %d occupied positions" % [walls_tilemap.positions_open_room.size(), occupied_positions.size()])
	
	for room_pos in walls_tilemap.positions_open_room:
		var world_pos = walls_tilemap.to_global(room_pos)
		if not is_position_occupied(world_pos):
			available_positions.append(world_pos)
	
	print("[PlacementManager] Found %d available positions out of %d total room positions" % [available_positions.size(), walls_tilemap.positions_open_room.size()])
	return available_positions

# Safe placement for any interactable that avoids collisions
func place_interactable_safely(node: Node2D, walls_tilemap) -> bool:
	var available_positions = get_available_room_positions(walls_tilemap)
	
	if available_positions.size() == 0:
		print('[PlacementManager] No available positions for: ' + node.name)
		return false
	
	var chosen_pos = available_positions[randi() % available_positions.size()]
	print('[PlacementManager] Placing %s at position: %s' % [node.name, chosen_pos])
	node.global_position = chosen_pos
	mark_position_occupied(chosen_pos)
	return true
