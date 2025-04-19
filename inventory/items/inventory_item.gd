extends Resource

class_name InventoryItem

@export var name: String = ""
@export var description: String = ""
@export var texture: Texture2D
@export var sell_price: int

func consume(player: Player) -> bool:
	return false # Implemented by each item
