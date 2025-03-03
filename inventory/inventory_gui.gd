extends Control

class_name InventoryGUI

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://inventory/player_inventory_res.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	inventory.connect("inventory_updated", _on_inventory_updated)
	update()
	$TextureRect.hide()
	for i in range(slots.size()):
		print('[InventoryGUI] connecting slot with item_sold ', i)
		slots[i].connect("item_sold", _on_item_sold)

func _on_item_sold(item_slot: InventorySlot):
	InteractionManager.sell_item(item_slot.item, item_slot.amount)
	
func _on_inventory_updated():
	print('[InventoryGUI] inventory updated')
	update()

func update():
	for i in range(min(inventory.itemSlots.size(), slots.size())):
		print('[InventoryGUI] updating item in slot ', i, inventory.itemSlots[i].item)
		slots[i].update_slot(inventory.itemSlots[i])

func add_item(item: InventoryItem):
	print('[InventoryGUI] inserting item')
	inventory.insert(item)

func open():
	self.visible = true
	self.isOpen = true
	opened.emit()

func close():
	self.visible = false
	self.isOpen = false
	closed.emit()
	
func activate_sell_mode():
	$TextureRect.show()
	for i in range(min(inventory.itemSlots.size(), slots.size())):
		print('[InventoryGUI] sell mode item in slot ', i, inventory.itemSlots[i].item)
		slots[i].set_on_sell_mode(true)

func deactivate_sell_mode():
	$TextureRect.hide()
	for i in range(min(inventory.itemSlots.size(), slots.size())):
		print('[InventoryGUI] deactivate_sell_mode mode item in slot ', i, inventory.itemSlots[i].item)
		slots[i].set_on_sell_mode(false)
