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
	
	if source_id < 0: return null 
	
	var scene_source = self.tile_set.get_source(source_id)
	var alt_id = self.get_cell_alternative_tile(cords)
	
	if scene_source is not TileSetScenesCollectionSource: return null

	# The assigned PackedScene.
	return scene_source.get_scene_tile_scene(alt_id)
	
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
			var item = scene_instance.collect() 
			if item:
				inventoryGUI.add_item(item)
				print("item collected",  item)
			else:
				print("no item defined for scene")

		else:
			print("The scene does not have a collect method or is not Area2D.")
	else:
		print("No scene found at the given tile.")

	set_cell(tileset_cords, -1)  # -1 deletes the tile
