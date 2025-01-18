extends Resource

class_name Inventory

@export var itemSlots: Array[InventorySlot]

func insert(item: InventoryItem):
	for i in range(itemSlots.size()):
		if itemSlots[i].item == item:
			itemSlots[i].amount += 1
			return

		if !itemSlots[i].item:
			itemSlots[i].item = item
			itemSlots[i].amount = 1
			return
