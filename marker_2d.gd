extends Marker2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_travel_area_stair_position(global_position_stair: Vector2) -> void:
	self.global_position = global_position_stair
