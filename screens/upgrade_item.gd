extends PanelContainer

@onready var name_label = $HBoxContainer/VBoxContainer/NameLabel
@onready var description_label = $HBoxContainer/VBoxContainer/MarginContainer/DescriptionLabel
@onready var cost_label = $HBoxContainer/VBoxContainer/CostContainer/CostLabel
@onready var buy_button = $HBoxContainer/VBoxContainer/CostContainer/MarginContainer/BuyButton
@onready var upgrade_icon = $HBoxContainer/IconContainer/IconMargin/UpgradeIcon

var upgrade_data: Dictionary
var parent_screen

func setup_upgrade(data: Dictionary, screen):
	upgrade_data = data
	parent_screen = screen
	
	name_label.text = data.name
	description_label.text = data.description
	cost_label.text = str(data.cost_gold) + "G + " + str(data.cost_minerals) + "M"
	
	# Load texture from path if it exists
	if data.texture_path != "":
		upgrade_icon.texture = load(data.texture_path)
	
	if data.purchased:
		buy_button.text = "OWNED"
		buy_button.disabled = true
		modulate = Color(0.7, 0.7, 0.7, 1.0)
	else:
		buy_button.text = "BUY"
		buy_button.disabled = false
		modulate = Color.WHITE
		
		# Check if player can afford it
		if not parent_screen.can_afford_upgrade(data):
			buy_button.disabled = true
			modulate = Color(1.0, 0.8, 0.8, 1.0)
	
	buy_button.pressed.connect(_on_buy_button_pressed)

func _on_buy_button_pressed():
	parent_screen.purchase_upgrade(upgrade_data) 
