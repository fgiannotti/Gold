extends Area2D

# Generic collectable, use it if it fulfills your needs
# Or create your own .gd if you need to extend it (more variables)
class_name Collectable

@export var collectableAsItem: InventoryItem
@export var texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collect() -> InventoryItem:
	print('collect called')
	queue_free()
	return collectableAsItem
