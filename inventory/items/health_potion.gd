class_name HealthPotion extends InventoryItem

@export var recover_value: int

func consume(player: Player) -> void:
	PlayerManager.set_health(PlayerManager.health + recover_value)
	print('consuming potion')
