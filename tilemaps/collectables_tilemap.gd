extends TileMapLayer

@export var inventoryGUI: InventoryGUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
	#print('setting coal in cell 2,1 with custom resource during runtime')
	#var coal_instance: Node = preload("res://collectables/minerals/mineral.tscn").instantiate()
	#coal_instance.mineral_data = load("res://collectables/minerals/coal/mineral_data_coal_left.tres") 
	#spawn_scene_at_tile(Vector2i(2,1), coal_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_scene_at_tile(tile_coords: Vector2i, instance: Node):
	instance.position = map_to_local(tile_coords)  # Align to tile position
	#set_cell(tile_coords, 0, Vector2i(0, 0), 0)
	add_child.call_deferred(instance)  # Add as a child to the TileMapLayer

func collectable_at_tile(tileset_cords: Vector2i) -> Node2D:
	# Convert the tilemap coordinates to world position
	var world_position = map_to_local(tileset_cords)

	for child in get_children():
		# Check if the child is a Node2D and its position matches the world position
		if child is Node2D and child.position == world_position:
			return child

	return null

func collectable_at_world_pos(world_cords: Vector2i):
	var tileset_cords = self.local_to_map(world_cords)
	print('cords mapped to local ', world_cords, '  in tileset : ', tileset_cords)
	
	return collectable_at_tile(tileset_cords)
	
func collect_tile(cords: Vector2i):
	var tileset_cords = self.local_to_map(cords)
	print('cords mapped to local ', cords, '  in tileset : ', tileset_cords)
	
	var node: Node2D = collectable_at_tile(tileset_cords)
	if not node: print("No node found at the given tile."); return
	if  !node.has_method("collect"): print("The scene does not have a collect method"); return

	var item = await node.collect()
	if not item: print("Node did not return item...", node.name); return
	print("item collected from node, persisting it ",  item.name)
	inventoryGUI.add_item(item)
	print("item collected",  item)

	set_cell(tileset_cords, -1)  # -1 deletes the tile
