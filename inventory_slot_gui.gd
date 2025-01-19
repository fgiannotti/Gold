extends Panel

@onready var background_sprite: Sprite2D = $Background
@onready var item_sprite: Sprite2D = $CenterContainer/Panel/Item
@onready var label: Label = $CenterContainer/Panel/Label

func update_slot(itemSlot: InventorySlot):
	if itemSlot.item:
		background_sprite.frame = 1
		item_sprite.visible = true
		item_sprite.texture = itemSlot.item.texture
		label.text = String.num(itemSlot.amount)
	else:
		background_sprite.frame = 0
		item_sprite.visible = false
