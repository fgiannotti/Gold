extends StaticBody2D

signal item_hovered(shop_item: ShopItem)

var shop_item: ShopItem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set_meta("Shop Item Name", "Slime Tears")  # Store the name in metadata
	add_to_group("shop_items")  # Add this item to the "shop_items" group


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interactable_area_body_entered(body: Node2D) -> void:
	print("🚀 Emitting item_hovered for:", shop_item)
	item_hovered.emit(shop_item)

func set_shop_item(new_shop_item: ShopItem):
	shop_item = new_shop_item
	$Sprite2D.texture = new_shop_item.inventoryItem.texture
	
