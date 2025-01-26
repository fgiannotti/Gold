extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var map_pos = $"../../Player".position
	self.text = str(map_pos) + " and "+ str($"../../TileMap/walls".local_to_map(map_pos))
