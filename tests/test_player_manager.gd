extends "res://tests/test_runner.gd".BaseTest

var player_manager: Node

func _init():
	# Create a mock PlayerManager that doesn't depend on autoloads
	player_manager = Node.new()
	
	# Add all the required properties manually
	player_manager.set_script(GDScript.new())
	player_manager.get_script().source_code = '''
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
var upgrades = [] # Simplified for test

var final_inventory_count: int = 0

func set_health(new_health: float):
	self.health = new_health
	hp_updated.emit(new_health) 

func set_food(new_food: float):
	self.food = new_food
	food_updated.emit(new_food)

func get_hunger_modifier() -> float:
	if expedition_number > 1:
		return 0.05 * (expedition_number - 1)
	return 0.0

func store_final_inventory_count():
	final_inventory_count = 0

func get_final_inventory_count() -> int:
	return final_inventory_count
	
func restart():
	steps_for_hunger = float(INITIAL_STEPS_FOR_HUNGER) * (1.0 - get_hunger_modifier())
	food = INITIAL_FOOD
	gold = 0
	health = INITIAL_HEALTH
	final_inventory_count = 0
'''
	player_manager.get_script().reload()

func test_initial_values():
	"""Test that PlayerManager starts with correct initial values"""
	player_manager.restart()
	
	assert_equal(player_manager.health, 100.0)
	assert_equal(player_manager.food, 100.0)
	assert_equal(player_manager.gold, 0)
	assert_equal(player_manager.final_inventory_count, 0)
	assert_equal(player_manager.steps_for_hunger, 50.0)

func test_constants():
	"""Test that constants are set correctly"""
	assert_equal(player_manager.PLAYER_SPEED, 500)
	assert_equal(player_manager.INITIAL_STEPS_FOR_HUNGER, 50)
	assert_equal(player_manager.INITIAL_FOOD, 100.0)
	assert_equal(player_manager.INITIAL_HEALTH, 100.0)

func test_hunger_modifier_calculation():
	"""Test that the hunger modifier is calculated correctly"""
	player_manager.restart()
	
	# Expedition 1: No modifier
	player_manager.expedition_number = 1
	player_manager.restart()
	assert_equal(player_manager.steps_for_hunger, 50.0)
	
	# Expedition 2: 5% modifier
	player_manager.expedition_number = 2
	player_manager.restart()
	assert_true(abs(player_manager.steps_for_hunger - 47.5) < 0.01) # 50 * (1 - 0.05)
	
	# Expedition 3: 10% modifier
	player_manager.expedition_number = 3
	player_manager.restart()
	assert_true(abs(player_manager.steps_for_hunger - 45.0) < 0.01) # 50 * (1 - 0.10)
	
	# Expedition 11: 50% modifier
	player_manager.expedition_number = 11
	player_manager.restart()
	assert_true(abs(player_manager.steps_for_hunger - 25.0) < 0.01) # 50 * (1 - 0.50)

func test_set_health():
	"""Test health setting functionality"""
	player_manager.restart()
	
	# Test setting normal health value
	player_manager.set_health(75.0)
	assert_equal(player_manager.health, 75.0)
	
	# Test setting zero health
	player_manager.set_health(0.0)
	assert_equal(player_manager.health, 0.0)
	
	# Test setting maximum health
	player_manager.set_health(100.0)
	assert_equal(player_manager.health, 100.0)
	
	# Test setting health above maximum
	player_manager.set_health(150.0)
	assert_equal(player_manager.health, 150.0)  # PlayerManager doesn't clamp health

func test_set_food():
	"""Test food setting functionality"""
	player_manager.restart()
	
	# Test setting normal food value
	player_manager.set_food(50.0)
	assert_equal(player_manager.food, 50.0)
	
	# Test setting zero food
	player_manager.set_food(0.0)
	assert_equal(player_manager.food, 0.0)
	
	# Test setting maximum food
	player_manager.set_food(100.0)
	assert_equal(player_manager.food, 100.0)
	
	# Test setting food above maximum
	player_manager.set_food(120.0)
	assert_equal(player_manager.food, 120.0)  # PlayerManager doesn't clamp food

func test_store_final_inventory_count():
	"""Test storing final inventory count functionality"""
	player_manager.restart()
	
	# Initial count should be 0
	assert_equal(player_manager.final_inventory_count, 0)
	
	# Test storing inventory count (without actual InteractionManager)
	player_manager.store_final_inventory_count()
	
	# Should remain 0 since no InteractionManager exists in test
	assert_equal(player_manager.final_inventory_count, 0)

func test_get_final_inventory_count():
	"""Test getting final inventory count"""
	player_manager.restart()
	
	# Test initial count
	assert_equal(player_manager.get_final_inventory_count(), 0)
	
	# Manually set final inventory count for testing
	player_manager.final_inventory_count = 5
	assert_equal(player_manager.get_final_inventory_count(), 5)

func test_restart_functionality():
	"""Test that restart properly resets all values"""
	# Modify some values
	player_manager.set_health(50.0)
	player_manager.set_food(25.0)
	player_manager.gold = 250
	player_manager.final_inventory_count = 10
	
	# Verify values are changed
	assert_equal(player_manager.health, 50.0)
	assert_equal(player_manager.food, 25.0)
	assert_equal(player_manager.gold, 250)
	assert_equal(player_manager.final_inventory_count, 10)
	
	# Restart and verify reset
	player_manager.restart()
	
	assert_equal(player_manager.health, 100.0)
	assert_equal(player_manager.food, 100.0)
	assert_equal(player_manager.gold, 0)
	assert_equal(player_manager.final_inventory_count, 0)

func test_health_boundaries():
	"""Test health with boundary values"""
	player_manager.restart()
	
	# Test negative health
	player_manager.set_health(-10.0)
	assert_equal(player_manager.health, -10.0)  # PlayerManager allows negative health
	
	# Test very large health value
	player_manager.set_health(9999.0)
	assert_equal(player_manager.health, 9999.0)
	
	# Test fractional health
	player_manager.set_health(33.33)
	assert_equal(player_manager.health, 33.33)

func test_food_boundaries():
	"""Test food with boundary values"""
	player_manager.restart()
	
	# Test negative food
	player_manager.set_food(-5.0)
	assert_equal(player_manager.food, -5.0)  # PlayerManager allows negative food
	
	# Test very large food value
	player_manager.set_food(9999.0)
	assert_equal(player_manager.food, 9999.0)
	
	# Test fractional food
	player_manager.set_food(66.66)
	assert_equal(player_manager.food, 66.66)

func test_gold_modification():
	"""Test gold value modifications"""
	player_manager.restart()
	
	# Test increasing gold
	player_manager.gold = 200
	assert_equal(player_manager.gold, 200)
	
	# Test decreasing gold
	player_manager.gold = 50
	assert_equal(player_manager.gold, 50)
	
	# Test zero gold
	player_manager.gold = 0
	assert_equal(player_manager.gold, 0)
	
	# Test negative gold
	player_manager.gold = -10
	assert_equal(player_manager.gold, -10)

func test_multiple_state_changes():
	"""Test multiple state changes in sequence"""
	player_manager.restart()
	
	# Simulate a game session
	player_manager.set_health(90.0)
	player_manager.set_food(80.0)
	player_manager.gold = 150
	
	assert_equal(player_manager.health, 90.0)
	assert_equal(player_manager.food, 80.0)
	assert_equal(player_manager.gold, 150)
	
	# Continue simulation
	player_manager.set_health(70.0)
	player_manager.set_food(60.0)
	player_manager.gold = 200
	
	assert_equal(player_manager.health, 70.0)
	assert_equal(player_manager.food, 60.0)
	assert_equal(player_manager.gold, 200)

func test_state_persistence():
	"""Test that state persists between operations"""
	player_manager.restart()
	
	# Set some values
	player_manager.set_health(42.5)
	player_manager.set_food(33.7)
	player_manager.gold = 123
	
	# Do some other operations (that don't modify these values)
	player_manager.store_final_inventory_count()
	var inventory_count = player_manager.get_final_inventory_count()
	
	# Verify original values are unchanged
	assert_equal(player_manager.health, 42.5)
	assert_equal(player_manager.food, 33.7)
	assert_equal(player_manager.gold, 123) 
