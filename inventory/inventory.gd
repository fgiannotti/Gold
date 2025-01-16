extends Resource

class_name Inventory

@export var items: Array[InventoryItem]

func insert(item: InventoryItem):
	self.items.append(item)
