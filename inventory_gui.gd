extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://inventory/player_inventory_res.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	update()
	
func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update_slot(inventory.items[i])

func open():
	self.visible = true
	self.isOpen = true
	opened.emit()

func close():
	self.visible = false
	self.isOpen = false
	closed.emit()
