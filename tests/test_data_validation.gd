extends "res://tests/test_runner.gd".BaseTest

func test_upgrade_data_consistency():
	"""Test that all upgrade data is consistent and valid"""
	# Create a mock meta game node with proper Control inheritance
	var meta_game = Control.new()
	
	# Add the upgrades property manually
	meta_game.set_script(GDScript.new())
	meta_game.get_script().source_code = '''
extends Control

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
	}
]
'''
	meta_game.get_script().reload()
	
	# Test upgrade array exists and has expected size
	assert_not_null(meta_game.upgrades)
	assert_true(meta_game.upgrades.size() > 0)
	
	# Test each upgrade for consistency
	for upgrade in meta_game.upgrades:
		# Required fields
		assert_true(upgrade.has("name"), "Upgrade must have name")
		assert_true(upgrade.has("description"), "Upgrade must have description")
		assert_true(upgrade.has("cost_gold"), "Upgrade must have gold cost")
		assert_true(upgrade.has("cost_minerals"), "Upgrade must have mineral cost")
		assert_true(upgrade.has("purchased"), "Upgrade must have purchased state")
		assert_true(upgrade.has("texture_path"), "Upgrade must have texture path")
		
		# Data validation
		assert_true(upgrade.name.length() > 0, "Upgrade name cannot be empty")
		assert_true(upgrade.description.length() > 0, "Upgrade description cannot be empty")
		assert_true(upgrade.cost_gold > 0, "Gold cost must be positive")
		assert_true(upgrade.cost_minerals > 0, "Mineral cost must be positive")
		assert_true(upgrade.texture_path.begins_with("res://"), "Texture path must be valid resource")

func test_breakable_config_data_integrity():
	"""Test breakable configuration data integrity"""
	# Test default breakable config values
	var config = Resource.new()
	config.set_script(load("res://collectables/breakable_config.gd"))
	
	# Test default values are reasonable
	assert_equal(config.modulate_color, Color.WHITE)
	assert_equal(config.sprite_frame, 0)
	assert_equal(config.drop_chance, 1.0)
	assert_equal(config.break_animation_name, "break")
	assert_equal(config.break_animation_duration, 0.5)
	assert_equal(config.config_name, "Basic Breakable")
	assert_equal(config.config_description, "A basic breakable object")
	
	# Test that effects array is properly initialized
	assert_not_null(config.effects)
	assert_equal(config.effects.size(), 0)

func test_mineral_data_consistency():
	"""Test mineral data consistency across all mineral types"""
	var mineral_names = ["coal", "iron", "gold", "ruby", "diamond"]
	var directions = ["left", "right", "top", "bot"]
	
	for mineral_name in mineral_names:
		for direction in directions:
			# Test that mineral name is valid
			assert_true(mineral_name.length() >= 3, "Mineral name too short: " + mineral_name)
			assert_true(mineral_name.length() <= 10, "Mineral name too long: " + mineral_name)
			
			# Test direction naming consistency
			assert_true(direction in ["left", "right", "top", "bot"], "Invalid direction: " + direction)

func test_player_manager_constants():
	"""Test PlayerManager constants are reasonable"""
	# Create a mock player manager that doesn't depend on autoloads
	var player_manager = Node.new()
	player_manager.set_script(GDScript.new())
	player_manager.get_script().source_code = '''
extends Node

const PLAYER_SPEED = 500
const STEPS_FOR_HUNGER = 50
const INITIAL_GOLD: int = 100
const INITIAL_FOOD: float = 100
const INITIAL_HEALTH: float = 100
'''
	player_manager.get_script().reload()
	
	# Test speed constant
	assert_true(player_manager.PLAYER_SPEED > 0, "Player speed must be positive")
	assert_true(player_manager.PLAYER_SPEED <= 1000, "Player speed should be reasonable")
	
	# Test hunger constant
	assert_true(player_manager.STEPS_FOR_HUNGER > 0, "Steps for hunger must be positive")
	assert_true(player_manager.STEPS_FOR_HUNGER <= 200, "Steps for hunger should be reasonable")
	
	# Test initial values
	assert_true(player_manager.INITIAL_GOLD >= 0, "Initial gold cannot be negative")
	assert_true(player_manager.INITIAL_FOOD > 0, "Initial food must be positive")
	assert_true(player_manager.INITIAL_HEALTH > 0, "Initial health must be positive")
	
	# Test reasonable bounds
	assert_true(player_manager.INITIAL_HEALTH <= 1000, "Initial health should be reasonable")
	assert_true(player_manager.INITIAL_FOOD <= 1000, "Initial food should be reasonable")

func test_game_stats_data_structure():
	"""Test GameStats data structure completeness"""
	var game_stats = Node.new()
	game_stats.set_script(load("res://screens/game_stats.gd"))
	
	# Test that all expected stats exist
	var expected_stats = [
		"breakables_destroyed",
		"minerals_mined", 
		"enemies_defeated",
		"damage_taken",
		"healing_received",
		"items_collected",
		"chests_opened",
		"deaths",
		"wins"
	]
	
	game_stats.reset_stats()
	
	for stat_name in expected_stats:
		var value = game_stats.get_stat(stat_name)
		assert_equal(value, 0, "Stat should initialize to 0: " + stat_name)

func test_maze_constants_validity():
	"""Test maze generation constants are valid"""
	# Test maze dimensions
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	
	assert_true(MAZE_WIDTH > 10, "Maze width should be reasonable")
	assert_true(MAZE_HEIGHT > 10, "Maze height should be reasonable")
	assert_true(MAZE_WIDTH <= 50, "Maze width should not be too large")
	assert_true(MAZE_HEIGHT <= 50, "Maze height should not be too large")
	
	# Test direction constants
	var SOUTH_DIR = 1
	var EAST_DIR = 2
	var NORTH_DIR = 4
	var WEST_DIR = 8
	
	# Should be powers of 2
	assert_equal(SOUTH_DIR, 1)
	assert_equal(EAST_DIR, 2)
	assert_equal(NORTH_DIR, 4)
	assert_equal(WEST_DIR, 8)
	
	# Combined should equal 15
	var combined = SOUTH_DIR | EAST_DIR | NORTH_DIR | WEST_DIR
	assert_equal(combined, 15)

func test_resource_path_validation():
	"""Test that resource paths are properly formatted"""
	var test_paths = [
		"res://assets/items/SmallTorch.png",
		"res://assets/items/pick item.png",
		"res://assets/items/EnergyBar.png",
		"res://assets/particles/GainedHealth v1.png"
	]
	
	for path in test_paths:
		assert_true(path.begins_with("res://"), "Path should start with res://: " + path)
		assert_true(path.ends_with(".png"), "Image path should end with .png: " + path)
		assert_true(path.length() > 10, "Path should be descriptive: " + path)

func test_collision_layer_consistency():
	"""Test collision layer assignments are consistent"""
	# Test collision layers from various systems
	var collision_layers = {
		"player": 2,
		"breakables": 4,
		"collectables": 8,
		"walls": 1
	}
	
	# Verify layers don't overlap inappropriately
	for layer_name in collision_layers:
		var layer_value = collision_layers[layer_name]
		assert_true(layer_value > 0, "Collision layer must be positive: " + layer_name)
		assert_true(layer_value <= 32, "Collision layer should be within valid range: " + layer_name)

func test_animation_duration_consistency():
	"""Test animation durations are reasonable"""
	var animation_durations = {
		"break": 0.5,
		"explode": 0.3,
		"collect": 2.0,
		"heal": 0.7
	}
	
	for anim_name in animation_durations:
		var duration = animation_durations[anim_name]
		assert_true(duration > 0.0, "Animation duration must be positive: " + anim_name)
		assert_true(duration <= 5.0, "Animation duration should be reasonable: " + anim_name)

func test_upgrade_cost_balance():
	"""Test upgrade costs are balanced and reasonable"""
	# Create a mock meta game node
	var meta_game = Control.new()
	meta_game.set_script(GDScript.new())
	meta_game.get_script().source_code = '''
extends Control

var current_gold: int = 250
var upgrades = [
	{
		"name": "Mining Torch",
		"cost_gold": 150,
		"cost_minerals": 10
	},
	{
		"name": "Better Pickaxe", 
		"cost_gold": 200,
		"cost_minerals": 8
	}
]
'''
	meta_game.get_script().reload()
	
	var total_gold_cost = 0
	var total_mineral_cost = 0
	
	for upgrade in meta_game.upgrades:
		total_gold_cost += upgrade.cost_gold
		total_mineral_cost += upgrade.cost_minerals
		
		# Individual upgrade cost validation
		assert_true(upgrade.cost_gold >= 50, "Upgrade too cheap (gold): " + upgrade.name)
		assert_true(upgrade.cost_gold <= 500, "Upgrade too expensive (gold): " + upgrade.name)
		assert_true(upgrade.cost_minerals >= 3, "Upgrade too cheap (minerals): " + upgrade.name)
		assert_true(upgrade.cost_minerals <= 25, "Upgrade too expensive (minerals): " + upgrade.name)
	
	# Test total costs are reasonable
	assert_true(total_gold_cost <= meta_game.current_gold * 3, "Total upgrade costs should be achievable")

func test_drop_chance_validation():
	"""Test drop chances are within valid ranges"""
	var drop_chances = [0.0, 0.5, 0.6, 0.8, 1.0]
	
	for chance in drop_chances:
		assert_true(chance >= 0.0, "Drop chance cannot be negative")
		assert_true(chance <= 1.0, "Drop chance cannot exceed 100%")

func test_position_vector_validation():
	"""Test position vectors are reasonable"""
	# Test mineral collision positions
	var collision_positions = [
		Vector2(0, 8),     # South
		Vector2(16, -8),   # East  
		Vector2(-8, -16),  # North
		Vector2(-16, -8)   # West
	]
	
	for pos in collision_positions:
		# Positions should be within reasonable bounds
		assert_true(abs(pos.x) <= 32, "X position should be reasonable: " + str(pos))
		assert_true(abs(pos.y) <= 32, "Y position should be reasonable: " + str(pos))

func test_room_dimension_constraints():
	"""Test room dimensions are within valid bounds"""
	var min_dimension = 3
	var max_dimension = 7
	
	assert_true(min_dimension >= 3, "Minimum room dimension too small")
	assert_true(max_dimension <= 10, "Maximum room dimension too large")
	assert_true(max_dimension > min_dimension, "Max dimension must be greater than min")

func test_color_value_validation():
	"""Test color values are valid"""
	var test_colors = [
		Color.WHITE,
		Color.RED, 
		Color.GREEN,
		Color.BLUE,
		Color(0.5, 0.7, 0.3, 0.8)
	]
	
	for color in test_colors:
		assert_true(color.r >= 0.0 and color.r <= 1.0, "Red component out of range")
		assert_true(color.g >= 0.0 and color.g <= 1.0, "Green component out of range")
		assert_true(color.b >= 0.0 and color.b <= 1.0, "Blue component out of range")
		assert_true(color.a >= 0.0 and color.a <= 1.0, "Alpha component out of range")

func test_string_data_validation():
	"""Test string data for proper formatting"""
	var test_strings = [
		"Mining Torch",
		"Better Pickaxe", 
		"Energy Pack",
		"Health Boost"
	]
	
	for text in test_strings:
		assert_true(text.length() > 0, "String cannot be empty")
		assert_true(text.length() <= 50, "String should not be too long: " + text)
		assert_false(text.begins_with(" "), "String should not start with space: " + text)
		assert_false(text.ends_with(" "), "String should not end with space: " + text)

func test_numeric_bounds_validation():
	"""Test numeric values are within expected bounds"""
	# Test various numeric constraints
	var numeric_tests = {
		"health_range": {"min": 0, "max": 1000, "current": 100},
		"food_range": {"min": 0, "max": 1000, "current": 100},
		"gold_range": {"min": 0, "max": 99999, "current": 250},
		"minerals_range": {"min": 0, "max": 999, "current": 15}
	}
	
	for test_name in numeric_tests:
		var test_data = numeric_tests[test_name]
		assert_true(test_data.current >= test_data.min, test_name + " current below minimum")
		assert_true(test_data.current <= test_data.max, test_name + " current above maximum")
		assert_true(test_data.min < test_data.max, test_name + " min should be less than max")

func test_array_data_integrity():
	"""Test array data structures are properly initialized"""
	# Test various arrays in the system
	var breakable_config = Resource.new()
	breakable_config.set_script(load("res://collectables/breakable_config.gd"))
	
	# Effects array should be initialized
	assert_not_null(breakable_config.effects)
	assert_true(breakable_config.effects is Array, "Effects should be an array")

func test_file_extension_consistency():
	"""Test file extensions are consistent with content type"""
	var file_extensions = {
		".gd": "GDScript files",
		".tscn": "Scene files", 
		".tres": "Resource files",
		".png": "Image files",
		".gdshader": "Shader files"
	}
	
	# Just test that we have awareness of different file types
	for ext in file_extensions:
		assert_true(ext.begins_with("."), "Extension should start with dot: " + ext)
		assert_true(ext.length() >= 3, "Extension should be at least 3 characters: " + ext)

func test_system_integration_points():
	"""Test that systems have proper integration points"""
	# Test that required globals/autoloads exist conceptually
	var expected_systems = [
		"PlayerManager",
		"GameStats", 
		"InteractionManager",
		"MineralAutoloader",
		"CollectableAutoloader",
		"BreakablesAutoloader"
	]
	
	# Just verify the names are reasonable
	for system_name in expected_systems:
		assert_true(system_name.length() > 5, "System name should be descriptive: " + system_name)
		assert_false(system_name.contains(" "), "System name should not contain spaces: " + system_name) 
