extends Area2D

var auxStairPosition
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_walls_stair_ready(stairPosition: Variant) -> void:
	self.global_position = stairPosition
	auxStairPosition = stairPosition
	print('Area Position: ', self.global_position,)
