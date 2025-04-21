class_name RedApple extends InventoryItem

@export var recover_value: int

func consume(player: Player) -> bool:
	PlayerManager.set_food(PlayerManager.food + recover_value)
	print('[RedApple] consuming apple')
	return true
