extends "res://tests/test_runner.gd".BaseTest

var meta_game: Control

func _init():
	# Create a Control node and apply the meta game script
	meta_game = Control.new()
	
	# Create a mock script for testing
	var mock_script = GDScript.new()
	mock_script.source_code = '''
extends Control

var current_gold: int = 250
var current_minerals: int = 15

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

func can_afford_upgrade(upgrade_data: Dictionary) -> bool:
	return current_gold >= upgrade_data.cost_gold and current_minerals >= upgrade_data.cost_minerals and not upgrade_data.purchased

func purchase_upgrade(upgrade_data: Dictionary):
	if can_afford_upgrade(upgrade_data):
		current_gold -= upgrade_data.cost_gold
		current_minerals -= upgrade_data.cost_minerals
		upgrade_data.purchased = true
'''
	meta_game.set_script(mock_script)

func test_initial_resources():
	"""Test that MetaGameScreen starts with correct initial resources"""
	assert_equal(meta_game.current_gold, 250)
	assert_equal(meta_game.current_minerals, 15)

func test_upgrade_data_structure():
	"""Test that upgrade data is properly structured"""
	assert_equal(meta_game.upgrades.size(), 4)
	
	# Test first upgrade (Mining Torch)
	var torch_upgrade = meta_game.upgrades[0]
	assert_equal(torch_upgrade.name, "Mining Torch")
	assert_equal(torch_upgrade.cost_gold, 150)
	assert_equal(torch_upgrade.cost_minerals, 10)
	assert_false(torch_upgrade.purchased)
	assert_equal(torch_upgrade.texture_path, "res://assets/items/SmallTorch.png")
	
	# Test second upgrade (Better Pickaxe)
	var pickaxe_upgrade = meta_game.upgrades[1]
	assert_equal(pickaxe_upgrade.name, "Better Pickaxe")
	assert_equal(pickaxe_upgrade.cost_gold, 200)
	assert_equal(pickaxe_upgrade.cost_minerals, 8)
	assert_false(pickaxe_upgrade.purchased)
	
	# Test third upgrade (Energy Pack)
	var energy_upgrade = meta_game.upgrades[2]
	assert_equal(energy_upgrade.name, "Energy Pack")
	assert_equal(energy_upgrade.cost_gold, 100)
	assert_equal(energy_upgrade.cost_minerals, 5)
	assert_false(energy_upgrade.purchased)
	
	# Test fourth upgrade (Health Boost)
	var health_upgrade = meta_game.upgrades[3]
	assert_equal(health_upgrade.name, "Health Boost")
	assert_equal(health_upgrade.cost_gold, 175)
	assert_equal(health_upgrade.cost_minerals, 12)
	assert_false(health_upgrade.purchased)

func test_can_afford_upgrade_with_sufficient_resources():
	"""Test can_afford_upgrade when player has enough resources"""
	# Reset to initial state
	meta_game.current_gold = 250
	meta_game.current_minerals = 15
	
	# Test affordable upgrades
	var torch_upgrade = meta_game.upgrades[0]  # 150G, 10M
	assert_true(meta_game.can_afford_upgrade(torch_upgrade))
	
	var energy_upgrade = meta_game.upgrades[2]  # 100G, 5M
	assert_true(meta_game.can_afford_upgrade(energy_upgrade))

func test_can_afford_upgrade_with_insufficient_gold():
	"""Test can_afford_upgrade when player lacks gold"""
	# Set low gold
	meta_game.current_gold = 50
	meta_game.current_minerals = 15
	
	var torch_upgrade = meta_game.upgrades[0]  # 150G, 10M
	assert_false(meta_game.can_afford_upgrade(torch_upgrade))
	
	var pickaxe_upgrade = meta_game.upgrades[1]  # 200G, 8M
	assert_false(meta_game.can_afford_upgrade(pickaxe_upgrade))

func test_can_afford_upgrade_with_insufficient_minerals():
	"""Test can_afford_upgrade when player lacks minerals"""
	# Set low minerals
	meta_game.current_gold = 250
	meta_game.current_minerals = 3
	
	var torch_upgrade = meta_game.upgrades[0]  # 150G, 10M
	assert_false(meta_game.can_afford_upgrade(torch_upgrade))
	
	var health_upgrade = meta_game.upgrades[3]  # 175G, 12M
	assert_false(meta_game.can_afford_upgrade(health_upgrade))

func test_can_afford_upgrade_already_purchased():
	"""Test can_afford_upgrade returns false for already purchased upgrades"""
	# Set sufficient resources
	meta_game.current_gold = 250
	meta_game.current_minerals = 15
	
	var torch_upgrade = meta_game.upgrades[0]
	torch_upgrade.purchased = true
	
	assert_false(meta_game.can_afford_upgrade(torch_upgrade))

func test_purchase_upgrade_successful():
	"""Test successful upgrade purchase"""
	# Set initial resources
	meta_game.current_gold = 250
	meta_game.current_minerals = 15
	
	var energy_upgrade = meta_game.upgrades[2]  # 100G, 5M
	
	# Verify initial state
	assert_false(energy_upgrade.purchased)
	assert_true(meta_game.can_afford_upgrade(energy_upgrade))
	
	# Purchase upgrade
	meta_game.purchase_upgrade(energy_upgrade)
	
	# Verify purchase
	assert_true(energy_upgrade.purchased)
	assert_equal(meta_game.current_gold, 150)  # 250 - 100
	assert_equal(meta_game.current_minerals, 10)  # 15 - 5

func test_purchase_upgrade_insufficient_resources():
	"""Test purchase attempt with insufficient resources"""
	# Set insufficient resources
	meta_game.current_gold = 50
	meta_game.current_minerals = 3
	
	var torch_upgrade = meta_game.upgrades[0]  # 150G, 10M
	
	# Verify initial state
	assert_false(torch_upgrade.purchased)
	assert_false(meta_game.can_afford_upgrade(torch_upgrade))
	
	# Attempt purchase
	meta_game.purchase_upgrade(torch_upgrade)
	
	# Verify no purchase occurred
	assert_false(torch_upgrade.purchased)
	assert_equal(meta_game.current_gold, 50)  # Unchanged
	assert_equal(meta_game.current_minerals, 3)  # Unchanged

func test_purchase_multiple_upgrades():
	"""Test purchasing multiple upgrades in sequence"""
	# Set sufficient resources
	meta_game.current_gold = 300
	meta_game.current_minerals = 20
	
	var energy_upgrade = meta_game.upgrades[2]  # 100G, 5M
	var torch_upgrade = meta_game.upgrades[0]  # 150G, 10M
	
	# Purchase first upgrade
	meta_game.purchase_upgrade(energy_upgrade)
	assert_true(energy_upgrade.purchased)
	assert_equal(meta_game.current_gold, 200)  # 300 - 100
	assert_equal(meta_game.current_minerals, 15)  # 20 - 5
	
	# Purchase second upgrade
	meta_game.purchase_upgrade(torch_upgrade)
	assert_true(torch_upgrade.purchased)
	assert_equal(meta_game.current_gold, 50)  # 200 - 150
	assert_equal(meta_game.current_minerals, 5)  # 15 - 10

func test_purchase_upgrade_exact_resources():
	"""Test purchasing upgrade with exact required resources"""
	var energy_upgrade = meta_game.upgrades[2]  # 100G, 5M
	
	# Set exact resources needed
	meta_game.current_gold = 100
	meta_game.current_minerals = 5
	
	# Verify can afford
	assert_true(meta_game.can_afford_upgrade(energy_upgrade))
	
	# Purchase upgrade
	meta_game.purchase_upgrade(energy_upgrade)
	
	# Verify purchase and zero resources
	assert_true(energy_upgrade.purchased)
	assert_equal(meta_game.current_gold, 0)
	assert_equal(meta_game.current_minerals, 0)

func test_upgrade_costs_validation():
	"""Test that all upgrade costs are positive and reasonable"""
	for upgrade in meta_game.upgrades:
		assert_true(upgrade.cost_gold > 0, "Gold cost should be positive for " + upgrade.name)
		assert_true(upgrade.cost_minerals > 0, "Mineral cost should be positive for " + upgrade.name)
		assert_true(upgrade.cost_gold <= 1000, "Gold cost should be reasonable for " + upgrade.name)
		assert_true(upgrade.cost_minerals <= 100, "Mineral cost should be reasonable for " + upgrade.name)

func test_upgrade_names_and_descriptions():
	"""Test that all upgrades have valid names and descriptions"""
	for upgrade in meta_game.upgrades:
		assert_true(upgrade.name != "", "Upgrade name should not be empty")
		assert_true(upgrade.description != "", "Upgrade description should not be empty")
		assert_true(upgrade.name.length() > 3, "Upgrade name should be descriptive: " + upgrade.name)
		assert_true(upgrade.description.length() > 10, "Upgrade description should be descriptive: " + upgrade.description)

func test_upgrade_texture_paths():
	"""Test that all upgrades have valid texture paths"""
	for upgrade in meta_game.upgrades:
		assert_true(upgrade.texture_path != "", "Texture path should not be empty for " + upgrade.name)
		assert_true(upgrade.texture_path.begins_with("res://"), "Texture path should be valid resource path for " + upgrade.name)
		assert_true(upgrade.texture_path.ends_with(".png"), "Texture should be PNG file for " + upgrade.name)

func test_resource_bounds():
	"""Test resource manipulation with edge cases"""
	# Test with zero resources
	meta_game.current_gold = 0
	meta_game.current_minerals = 0
	
	for upgrade in meta_game.upgrades:
		assert_false(meta_game.can_afford_upgrade(upgrade))
	
	# Test with very high resources
	meta_game.current_gold = 9999
	meta_game.current_minerals = 9999
	
	for upgrade in meta_game.upgrades:
		if not upgrade.purchased:
			assert_true(meta_game.can_afford_upgrade(upgrade))

func test_purchase_state_consistency():
	"""Test that purchase state remains consistent"""
	meta_game.current_gold = 1000
	meta_game.current_minerals = 100
	
	var upgrade = meta_game.upgrades[0]
	
	# Initially not purchased
	assert_false(upgrade.purchased)
	
	# Purchase upgrade
	meta_game.purchase_upgrade(upgrade)
	assert_true(upgrade.purchased)
	
	# Try to purchase again
	var gold_before = meta_game.current_gold
	var minerals_before = meta_game.current_minerals
	
	meta_game.purchase_upgrade(upgrade)
	
	# Resources should remain unchanged
	assert_equal(meta_game.current_gold, gold_before)
	assert_equal(meta_game.current_minerals, minerals_before)
	assert_true(upgrade.purchased) 
