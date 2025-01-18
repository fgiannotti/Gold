extends TileMapLayer

@export var inventoryGUI: InventoryGUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("setting cell in 2,1 for testing")
	set_cell(Vector2i(2, 1), 0, Vector2i(0, 0), 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func scene_at_tile(cords: Vector2i) -> PackedScene:
	var source_id = self.get_cell_source_id(cords)
	get_used_cells_by_id()
	if source_id < 0: return null 
	
	var scene_source = self.tile_set.get_source(source_id)
	var alt_id = self.get_cell_alternative_tile(cords)
	
	if scene_source is not TileSetScenesCollectionSource: return null

	# The assigned PackedScene.
	return scene_source.get_scene_tile_scene(alt_id)

func collectable_at_tile(tileset_cords: Vector2i) -> Node2D:
	# Convert the tilemap coordinates to world position
	var world_position = map_to_local(tileset_cords)
	
	# Iterate through all child nodes
	for child in get_children():
		# Check if the child is a Node2D and its position matches the world position
		if child is Node2D and child.global_position == world_position:
			return child
	
	# If no matching child is found, return null
	return null

func mine_tile(cords: Vector2i):
	var tileset_cords = self.local_to_map(cords)
	print('cords mapped to local ', cords, '  in tileset : ', tileset_cords)
	
	var node: Node2D = collectable_at_tile(tileset_cords)
	if not node: print("No node found at the given tile."); return
	if node is not Area2D or !node.has_method("collect"): print("The scene does not have a collect method or is not Area2D."); return
	
	var item = node.collect()
	if not item: print("Node did not return item...", node.name); return
	inventoryGUI.add_item(item)
	print("item collected",  item)

	set_cell(tileset_cords, -1)  # -1 deletes the tile
