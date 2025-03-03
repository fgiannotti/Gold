extends Resource

class_name Inventory

signal inventory_updated

@export var itemSlots: Array[InventorySlot]

func insert(item: InventoryItem):
	print('[Inventory] inserting item: ', item.name)
	for i in range(itemSlots.size()):
		if itemSlots[i].item == item:
			print('[Inventory] item increased in pos: ', i, item.name)
			itemSlots[i].amount += 1
			inventory_updated.emit()
			return

		if !itemSlots[i].item:
			itemSlots[i].item = item
			itemSlots[i].amount = 1
			print('[Inventory] item inserted in pos: ', i, item.name)
			inventory_updated.emit()
			return

func delete(item: InventoryItem):
	print('[Inventory] deleting item: ', item.name)
	for i in range(itemSlots.size()):
		if itemSlots[i].item == item:
			print('[Inventory] item deleted in pos: ', i, item.name)
			itemSlots[i].amount = 0
			itemSlots[i].item = null
			inventory_updated.emit()
			return
