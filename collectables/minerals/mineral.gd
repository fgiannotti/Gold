extends Node2D

# Generic collectable, use it if it fulfills your needs
# Or create your own .gd if you need to extend it (more variables)
class_name Mineral

@export var mineral_data: MineralData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = mineral_data.texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collect() -> InventoryItem:
	print('mineral collect called!')
	queue_free()
	return mineral_data.collectableAsItem
