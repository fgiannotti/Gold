extends TileMapLayer

@export var inventoryGUI: InventoryGUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("setting cell in 2,4")
	#set_cell(Vector2i(2, 2), 0, Vector2i(0, 0), 1)
	set_cell(Vector2i(2, 1), 0, Vector2i(0, 0), 1)
	var result = scene_at_tile(Vector2i(2,2))
	print("setting cell in 2,4", result)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func scene_at_tile(cords: Vector2i) -> PackedScene:
	var source_id = self.get_cell_source_id(cords)
	if source_id > -1:
		var scene_source = self.tile_set.get_source(source_id)
		if scene_source is TileSetScenesCollectionSource:
			var alt_id = self.get_cell_alternative_tile(cords)
			# The assigned PackedScene.
			return scene_source.get_scene_tile_scene(alt_id)
	return null
		
func mine_tile(cords: Vector2i):
	var tileset_cords = self.local_to_map(cords)
	print('cords mapped to local ', cords, '  in tileset : ', tileset_cords)
	
	# Get the PackedScene
	var packed_scene: PackedScene = scene_at_tile(tileset_cords)
	if packed_scene:
		# Instance the scene to create an instance
		var scene_instance = packed_scene.instantiate()
		
		# Check if the instance has the `collect` method
		if scene_instance is Area2D and scene_instance.has_method("collect"):
			var item = scene_instance.collect()  # Call the collect method
			if item:
				inventoryGUI.add_item(item)
				print("item collected",  item)
			else:
				print("no item defined for scene")

		else:
			print("The scene does not have a collect method or is not Area2D.")
	else:
		print("No scene found at the given tile.")

	# Remove the tile
	set_cell(tileset_cords, -1)  # -1 deletes the tile
