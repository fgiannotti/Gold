extends Panel

@onready var background_sprite: Sprite2D = $Background
@onready var item_sprite: Sprite2D = $CenterContainer/Panel/Item

func update_slot(item: InventoryItem):
	if item:
		background_sprite.frame = 1
		item_sprite.visible = true
		item_sprite.texture = item.texture
	else:
		background_sprite.frame = 0
		item_sprite.visible = false
