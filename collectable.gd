extends Area2D

class_name Collectable

@export var collectableStats: CollectableStats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collect() -> InventoryItem:
	print('collect called')
	queue_free()
	return collectableStats.item
