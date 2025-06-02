extends Control

@onready var gold_label = $VBoxContainer/ResourcesContainer/GoldContainer/GoldLabel
@onready var minerals_label = $VBoxContainer/ResourcesContainer/MineralsContainer/MineralsLabel
@onready var play_button = $VBoxContainer/ButtonsContainer/PlayButton
@onready var upgrades_container = $VBoxContainer/UpgradesContainer/ScrollContainer/UpgradesGrid

# Hardcoded resources for now
var current_gold: int = 250
var current_minerals: int = 15

# Simple upgrades system
var upgrades = [
	{
		"name": "Mining Torch",
		"description": "Torches will now appear randomly on each floor",
		"cost_gold": 150,
		"cost_minerals": 10,
		"purchased": false,
		"texture_path": "res://assets/items/SmallTorch.png"
	},
	{
		"name": "Better Pickaxe", 
		"description": "Mine minerals 25% faster",
		"cost_gold": 200,
		"cost_minerals": 8,
		"purchased": false,
		"texture_path": "res://assets/items/pick item.png"
	},
	{
		"name": "Energy Pack",
		"description": "Start each run with +50 food",
		"cost_gold": 100,
		"cost_minerals": 5,
		"purchased": false,
		"texture_path": "res://assets/items/EnergyBar.png"
	},
	{
		"name": "Health Boost",
		"description": "Start each run with +25 health",
		"cost_gold": 175,
		"cost_minerals": 12,
		"purchased": false,
		"texture_path": "res://assets/particles/GainedHealth v1.png"
	}
]

func _ready():
	update_display()
	setup_upgrades()
	play_button.pressed.connect(_on_play_button_pressed)

func update_display():
	gold_label.text = str(current_gold) + " G"
	minerals_label.text = str(current_minerals) + " Minerals"

func setup_upgrades():
	# Clear existing children
	for child in upgrades_container.get_children():
		child.queue_free()
	
	# Create upgrade items
	for upgrade in upgrades:
		create_upgrade_item(upgrade)

func create_upgrade_item(upgrade_data: Dictionary):
	var upgrade_item = preload("res://screens/upgrade_item.tscn").instantiate()
	upgrades_container.add_child(upgrade_item)  # Add to scene first
	upgrade_item.setup_upgrade(upgrade_data, self)  # Then setup after @onready vars are ready

func can_afford_upgrade(upgrade_data: Dictionary) -> bool:
	return current_gold >= upgrade_data.cost_gold and current_minerals >= upgrade_data.cost_minerals and not upgrade_data.purchased

func purchase_upgrade(upgrade_data: Dictionary):
	if can_afford_upgrade(upgrade_data):
		current_gold -= upgrade_data.cost_gold
		current_minerals -= upgrade_data.cost_minerals
		upgrade_data.purchased = true
		
		update_display()
		setup_upgrades()  # Refresh the upgrades display
		
		print("[MetaGameScreen] Purchased upgrade: ", upgrade_data.name)

func _on_play_button_pressed():
	# Add transition effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	get_tree().change_scene_to_file("res://screens/world.tscn") 
