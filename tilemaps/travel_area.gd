extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("travel_areas")  # Add to group for collision detection


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_walls_stair_decided(stair_position_in_world: Variant) -> void:
	self.global_position = stair_position_in_world
	print('Area Position: ', self.global_position,)
