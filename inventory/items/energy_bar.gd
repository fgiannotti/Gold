class_name EnergyBar extends InventoryItem

@export var recover_value: int

func consume(player: Player) -> bool:
	PlayerManager.set_food(PlayerManager.food + recover_value)
	print('[EnergyBar] consuming Energy Bar')
	return true
