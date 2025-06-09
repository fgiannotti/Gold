extends "res://tests/test_runner.gd".BaseTest

var breakable_config: Resource

func _init():
	# Create a mock BreakableConfig for testing
	breakable_config = Resource.new()
	breakable_config.set_script(load("res://collectables/breakable_config.gd"))

func test_default_values():
	"""Test that BreakableConfig has sensible default values"""
	assert_not_null(breakable_config.modulate_color)
	assert_equal(breakable_config.modulate_color, Color.WHITE)
	assert_equal(breakable_config.sprite_frame, 0)
	assert_equal(breakable_config.drop_chance, 1.0)
	assert_equal(breakable_config.break_animation_name, "break")
	assert_equal(breakable_config.break_animation_duration, 0.5)
	assert_equal(breakable_config.config_name, "Basic Breakable")
	assert_equal(breakable_config.config_description, "A basic breakable object")

func test_drop_chance_validation():
	"""Test drop chance boundary values"""
	# Test valid drop chances
	breakable_config.drop_chance = 0.0
	assert_equal(breakable_config.drop_chance, 0.0)
	
	breakable_config.drop_chance = 0.5
	assert_equal(breakable_config.drop_chance, 0.5)
	
	breakable_config.drop_chance = 1.0
	assert_equal(breakable_config.drop_chance, 1.0)
	
	# Test invalid drop chances (system should handle these gracefully)
	breakable_config.drop_chance = -0.1
	assert_equal(breakable_config.drop_chance, -0.1)  # Config doesn't validate, but consumers should
	
	breakable_config.drop_chance = 1.5
	assert_equal(breakable_config.drop_chance, 1.5)  # Config doesn't validate, but consumers should

func test_sprite_frame_values():
	"""Test sprite frame values"""
	breakable_config.sprite_frame = 0
	assert_equal(breakable_config.sprite_frame, 0)
	
	breakable_config.sprite_frame = 5
	assert_equal(breakable_config.sprite_frame, 5)
	
	# Negative values (invalid but should be handled by consumers)
	breakable_config.sprite_frame = -1
	assert_equal(breakable_config.sprite_frame, -1)

func test_animation_properties():
	"""Test animation-related properties"""
	# Test animation name
	breakable_config.break_animation_name = "explode"
	assert_equal(breakable_config.break_animation_name, "explode")
	
	breakable_config.break_animation_name = "shatter"
	assert_equal(breakable_config.break_animation_name, "shatter")
	
	# Test animation duration
	breakable_config.break_animation_duration = 0.1
	assert_equal(breakable_config.break_animation_duration, 0.1)
	
	breakable_config.break_animation_duration = 2.0
	assert_equal(breakable_config.break_animation_duration, 2.0)
	
	# Test zero duration
	breakable_config.break_animation_duration = 0.0
	assert_equal(breakable_config.break_animation_duration, 0.0)

func test_description_properties():
	"""Test config name and description properties"""
	# Test config name
	breakable_config.config_name = "Explosive Barrel"
	assert_equal(breakable_config.config_name, "Explosive Barrel")
	
	# Test config description
	breakable_config.config_description = "A dangerous barrel that explodes when attacked"
	assert_equal(breakable_config.config_description, "A dangerous barrel that explodes when attacked")
	
	# Test empty strings
	breakable_config.config_name = ""
	assert_equal(breakable_config.config_name, "")
	
	breakable_config.config_description = ""
	assert_equal(breakable_config.config_description, "")

func test_color_modulation():
	"""Test color modulation property"""
	# Test different colors
	breakable_config.modulate_color = Color.RED
	assert_equal(breakable_config.modulate_color, Color.RED)
	
	breakable_config.modulate_color = Color.GREEN
	assert_equal(breakable_config.modulate_color, Color.GREEN)
	
	breakable_config.modulate_color = Color.BLUE
	assert_equal(breakable_config.modulate_color, Color.BLUE)
	
	# Test transparent color
	breakable_config.modulate_color = Color.TRANSPARENT
	assert_equal(breakable_config.modulate_color, Color.TRANSPARENT)
	
	# Test custom color with alpha
	var custom_color = Color(0.5, 0.7, 0.3, 0.8)
	breakable_config.modulate_color = custom_color
	assert_equal(breakable_config.modulate_color, custom_color)

func test_effects_array():
	"""Test effects array functionality"""
	# Initially should be empty
	assert_not_null(breakable_config.effects)
	assert_equal(breakable_config.effects.size(), 0)
	
	# Create mock effects that are proper InteractableEffect resources
	var mock_effect1 = Resource.new()
	mock_effect1.set_script(load("res://collectables/breakables/interactable_effect.gd"))
	
	var mock_effect2 = Resource.new()
	mock_effect2.set_script(load("res://collectables/breakables/interactable_effect.gd"))
	
	# Test adding effects - since it's a TypedArray, we need proper types
	if breakable_config.effects is Array:
		# Clear the array first
		breakable_config.effects.clear()
		
		# Add effects directly through assignment
		breakable_config.effects = [mock_effect1]
		assert_equal(breakable_config.effects.size(), 1)
		
		# Add second effect
		breakable_config.effects = [mock_effect1, mock_effect2]
		assert_equal(breakable_config.effects.size(), 2)
		
		# Test clearing effects
		breakable_config.effects.clear()
		assert_equal(breakable_config.effects.size(), 0)

func test_resource_assignment():
	"""Test assignment of texture and collectable item resources"""
	# Test texture assignment (null initially)
	assert_null(breakable_config.texture)
	
	# Test collectable item assignment (null initially)
	assert_null(breakable_config.collectableAsItem)
	
	# Note: We can't create actual texture/item resources without the full Godot environment
	# But we can test that the properties exist and can be assigned

func test_configuration_completeness():
	"""Test that a complete configuration has all necessary fields"""
	# Set up a complete configuration
	breakable_config.config_name = "Test Pot"
	breakable_config.config_description = "A test pot for unit testing"
	breakable_config.break_animation_name = "break"
	breakable_config.break_animation_duration = 0.5
	breakable_config.drop_chance = 0.8
	breakable_config.sprite_frame = 0
	breakable_config.modulate_color = Color.WHITE
	
	# Verify all fields are set
	assert_true(breakable_config.config_name != "")
	assert_true(breakable_config.config_description != "")
	assert_true(breakable_config.break_animation_name != "")
	assert_true(breakable_config.break_animation_duration > 0.0)
	assert_true(breakable_config.drop_chance >= 0.0 and breakable_config.drop_chance <= 1.0)
	assert_true(breakable_config.sprite_frame >= 0)
	assert_not_null(breakable_config.modulate_color)

func test_animation_duration_boundaries():
	"""Test animation duration with edge cases"""
	# Very short duration
	breakable_config.break_animation_duration = 0.01
	assert_equal(breakable_config.break_animation_duration, 0.01)
	
	# Very long duration
	breakable_config.break_animation_duration = 10.0
	assert_equal(breakable_config.break_animation_duration, 10.0)
	
	# Negative duration (invalid but should be handled by consumers)
	breakable_config.break_animation_duration = -1.0
	assert_equal(breakable_config.break_animation_duration, -1.0)

func test_multiple_configurations():
	"""Test creating multiple different configurations"""
	# Create configurations for different breakable types
	var configs = []
	
	# Treasure chest config
	var chest_config = Resource.new()
	chest_config.set_script(load("res://collectables/breakable_config.gd"))
	chest_config.config_name = "Treasure Chest"
	chest_config.config_description = "Contains valuable items"
	chest_config.drop_chance = 1.0
	chest_config.modulate_color = Color(1.0, 0.8, 0.0, 1.0)  # Golden
	configs.append(chest_config)
	
	# Explosive trap config
	var trap_config = Resource.new()
	trap_config.set_script(load("res://collectables/breakable_config.gd"))
	trap_config.config_name = "Explosive Trap"
	trap_config.config_description = "Deals damage when triggered"
	trap_config.drop_chance = 0.0
	trap_config.modulate_color = Color(1.0, 0.5, 0.5, 1.0)  # Reddish
	trap_config.break_animation_name = "explode"
	trap_config.break_animation_duration = 0.3
	configs.append(trap_config)
	
	# Healing shrine config
	var shrine_config = Resource.new()
	shrine_config.set_script(load("res://collectables/breakable_config.gd"))
	shrine_config.config_name = "Healing Shrine"
	shrine_config.config_description = "Restores player health"
	shrine_config.drop_chance = 0.6
	shrine_config.modulate_color = Color(0.5, 1.0, 0.5, 1.0)  # Greenish
	shrine_config.break_animation_duration = 0.7
	configs.append(shrine_config)
	
	# Verify all configs are different and valid
	assert_equal(configs.size(), 3)
	
	for i in range(configs.size()):
		var config = configs[i]
		assert_true(config.config_name != "")
		assert_true(config.config_description != "")
		assert_true(config.drop_chance >= 0.0)
		assert_not_null(config.modulate_color)
		
		# Verify configs are actually different
		for j in range(configs.size()):
			if i != j:
				var other_config = configs[j]
				assert_true(config.config_name != other_config.config_name, "Config names should be unique")

func test_property_persistence():
	"""Test that property values persist correctly"""
	# Set some values
	breakable_config.config_name = "Persistent Test"
	breakable_config.drop_chance = 0.73
	breakable_config.sprite_frame = 7
	breakable_config.break_animation_duration = 1.25
	var test_color = Color(0.1, 0.2, 0.3, 0.4)
	breakable_config.modulate_color = test_color
	
	# Verify values persist
	assert_equal(breakable_config.config_name, "Persistent Test")
	assert_equal(breakable_config.drop_chance, 0.73)
	assert_equal(breakable_config.sprite_frame, 7)
	assert_equal(breakable_config.break_animation_duration, 1.25)
	assert_equal(breakable_config.modulate_color, test_color) 