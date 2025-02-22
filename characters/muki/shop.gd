extends Control


@onready var item_listing = $Background/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	self.populate_shop([
			{"name": "Health Potion", "price": 10},
			{"name": "Sword", "price": 50}
		])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	self.hide()


func populate_shop(items: Array):
	for item in items:
		var button = Button.new()
		button.text = item["name"] + " - " + str(item["price"]) + "G"
		button.pressed.connect(func(): _buy_item(item))
		item_listing.add_child(button)

func _buy_item(item):
	print("Buying:", item["name"])
	# Add logic to handle currency deduction and inventory updates
