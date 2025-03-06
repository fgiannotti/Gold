class_name HealthPotion extends InventoryItem

@export var recover_value: int

func consume(player: Player) -> void:
	Globals.set_health(Globals.health + recover_value)
	print('consuming potion')
