extends Node

const PLAYER_SPEED = 500
const INITIAL_STEPS_FOR_HUNGER = 50
var steps_for_hunger: float = INITIAL_STEPS_FOR_HUNGER

const INITIAL_FOOD: float = 100
const INITIAL_HEALTH: float = 100

signal hp_updated(new_hp: float)
signal food_updated(new_food: float)
signal meta_stats_changed

var health: float = INITIAL_HEALTH
var food: float = INITIAL_FOOD
var gold: int = 0

# Meta-game variables
var meta_gold: int = 0
var meta_minerals: int = 0
var expedition_number: int = 1
var upgrades = [
	{
		"name": "Mining Torch",
		"description": "Torches will now appear randomly on each floor",
		"cost_gold": 100,
		"cost_minerals": 10,
		"purchased": false,
		"texture_path": "res://assets/items/SmallTorch.png"
	},
	{
		"name": "Better Pickaxe", 
		"description": "Mine minerals 25% faster",
		"cost_gold": 120,
		"cost_minerals": 8,
		"purchased": false,
		"texture_path": "res://assets/items/relics/pick item.png"
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
		"cost_gold": 150,
		"cost_minerals": 12,
		"purchased": false,
		"texture_path": "res://assets/items/HealthPotion.png"
	}
]

# Store inventory data safely for end screens
var final_inventory_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_hunger_modifier() -> float:
	if expedition_number > 1:
		return 0.05 * (expedition_number - 1)
	return 0.0
	
func set_health(new_health: float):
	self.health = new_health
	hp_updated.emit(new_health) 

func set_food(new_food: float):
	self.food = new_food
	food_updated.emit(new_food) 

func apply_run_results(is_win: bool, run_gold: int, run_minerals: int):
	if is_win:
		meta_gold += run_gold
		meta_minerals += run_minerals
		expedition_number += 1
	else:
		meta_gold = 0
		meta_minerals = 0
		for upgrade in upgrades:
			upgrade.purchased = false
	meta_stats_changed.emit()

func purchase_upgrade(upgrade_data: Dictionary):
	if can_afford_upgrade(upgrade_data):
		meta_gold -= upgrade_data.cost_gold
		meta_minerals -= upgrade_data.cost_minerals
		upgrade_data.purchased = true
		meta_stats_changed.emit()

func can_afford_upgrade(upgrade_data: Dictionary) -> bool:
	return meta_gold >= upgrade_data.cost_gold and meta_minerals >= upgrade_data.cost_minerals and not upgrade_data.purchased

func store_final_inventory_count():
	"""Store the current inventory count safely before scene transitions"""
	final_inventory_count = 0
	
	# Safely count inventory items
	if InteractionManager and is_instance_valid(InteractionManager.inventoryGUI):
		if InteractionManager.inventoryGUI.inventory and is_instance_valid(InteractionManager.inventoryGUI.inventory):
			for slot in InteractionManager.inventoryGUI.inventory.itemSlots:
				if slot and slot.item != null and slot.amount > 0:
					final_inventory_count += slot.amount
	
	print("[PlayerManager] Stored final inventory count: ", final_inventory_count)

func get_final_inventory_count() -> int:
	"""Get the safely stored inventory count for end screens"""
	return final_inventory_count
	
func restart():
	# Apply purchased upgrades before starting a new run
	var starting_health = INITIAL_HEALTH
	var starting_food = INITIAL_FOOD
	
	for upgrade in upgrades:
		if upgrade.purchased:
			if upgrade.name == "Health Boost":
				starting_health += 25
			if upgrade.name == "Energy Pack":
				starting_food += 50

	# Calculate hunger penalty for subsequent expeditions
	steps_for_hunger = float(INITIAL_STEPS_FOR_HUNGER) * (1.0 - get_hunger_modifier())
	
	PlayerManager.food = starting_food
	PlayerManager.gold = 0
	PlayerManager.health = starting_health
	final_inventory_count = 0
	GameStats.reset_stats()
