class_name SlotHover extends PanelContainer

const coin_path = "[img=32x32]res://assets/inventory/coin-basic.png[/img]"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_hover_info(inventory_item: InventoryItem):
	print("[SlotHover] Got item name: ", inventory_item.name)
	print("[SlotHover] Got item desc: ", inventory_item.description)
	$VBoxContainer/TitleMargin/Title.text = inventory_item.name
	$VBoxContainer/DescriptionMargin/Description.text = inventory_item.description
	$VBoxContainer/PriceMargin/Price.text = "Sell Price: "  + str(inventory_item.sell_price) +"G " + coin_path
