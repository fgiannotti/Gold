class_name RedApple extends InventoryItem

@export var recover_value: int

func consume(player: Player) -> void:
	Globals.set_food(Globals.food + recover_value)
	print('[RedApple] consuming apple')
