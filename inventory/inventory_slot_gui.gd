extends Panel

@onready var background_sprite: Sprite2D = $Background
@onready var item_sprite: Sprite2D = $CenterContainer/Panel/Item
@onready var label: Label = $CenterContainer/Panel/Label

signal item_sold(item: InventorySlot)

var on_sell_mode = false
var mouse_on_item = true
var inventory_item_in_slot: InventorySlot = null

func set_on_sell_mode(val: bool):
	self.on_sell_mode = val

func _ready():
	$SlotHover.hide()

func _input(event):
	if event is InputEventMouseButton:
		if mouse_on_item == true && on_sell_mode && inventory_item_in_slot:
			item_sold.emit(self.inventory_item_in_slot)
			
func update_slot(itemSlot: InventorySlot):
	if itemSlot.item:
		background_sprite.frame = 1
		item_sprite.visible = true
		item_sprite.texture = itemSlot.item.texture
		label.text = String.num(itemSlot.amount)
		$SlotHover.set_hover_info(itemSlot.item)
		inventory_item_in_slot = itemSlot
	else:
		background_sprite.frame = 0
		label.text = "0"
		item_sprite.visible = false
		inventory_item_in_slot = null

func _on_mouse_entered() -> void:
	mouse_on_item = true
	if on_sell_mode && inventory_item_in_slot: $SlotHover.show()

func _on_mouse_exited() -> void:
	mouse_on_item = false
	$SlotHover.hide()
