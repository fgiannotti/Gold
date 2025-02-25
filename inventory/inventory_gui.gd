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

func _on_inventory_updated():
	print('inventory updated')
	update()

func update():
	for i in range(min(inventory.itemSlots.size(), slots.size())):
		print('updating item in slot ', i, inventory.itemSlots[i].item)
		slots[i].update_slot(inventory.itemSlots[i])

func add_item(item: InventoryItem):
	print('inserting item')
	inventory.insert(item)
	update()
	
func open():
	self.visible = true
	self.isOpen = true
	opened.emit()

func close():
	self.visible = false
	self.isOpen = false
	closed.emit()
