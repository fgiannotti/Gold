class_name Mineral extends Collectable

@export var mineral_data: MineralData

const collision_south_position = Vector2(0,8)
const collision_north_position = Vector2(-8,-16)
const collision_east_position = Vector2(16,-8)
const collision_west_position = Vector2(-16,-8)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = mineral_data.texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collect() -> InventoryItem:
	print('[Mineral] collect called!!')
	if !player_in_area:
		print('[Mineral] collect called but player no in area, returning...')
		return
	if collected:
		return null
	collected = true
	queue_free()
	return mineral_data.collectableAsItem

func use_collision_shape_from_direction(direction: int) -> void:
	if direction == 0: # S
		$CollectableArea/ColShape.position = collision_south_position
	elif direction == 1: # E
		$CollectableArea/ColShape.position = collision_east_position
	elif direction == 2: # N
		$CollectableArea/ColShape.position = collision_north_position
	elif direction == 3: # W
		$CollectableArea/ColShape.position = collision_west_position
