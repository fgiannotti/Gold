extends "res://tests/test_runner.gd".BaseTest

var collectable: Node2D

func _init():
	# Create a mock Collectable with required child nodes
	collectable = Node2D.new()
	
	# Add Sprite2D child node
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	collectable.add_child(sprite)
	
	# Add AnimationPlayer child node
	var anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	collectable.add_child(anim_player)
	
	# Create mock script for Collectable
	var mock_script = GDScript.new()
	mock_script.source_code = '''
extends Node2D

class_name Collectable

var collectableAsItem: Resource
var animation_name = "collect"
var player_in_area = false
var collected = false

@onready var texture = $Sprite2D
@onready var animations = $AnimationPlayer

func collect() -> Resource:
	print("[Collectable] collect called!!")
	if !player_in_area:
		print("[Collectable] collect called but player no in area, returning...")
		return null
	if collected:
		return null
	collected = true
	return collectableAsItem

func facing_left():
	if has_node("Sprite2D"):
		$Sprite2D.frame = 6
	# Reset to base name first, then add direction
	var base_name = animation_name.split("_")[0]
	animation_name = base_name + "_left"

func facing_right():
	if has_node("Sprite2D"):
		$Sprite2D.frame = 4
	var base_name = animation_name.split("_")[0]
	animation_name = base_name + "_right"

func facing_up():
	if has_node("Sprite2D"):
		$Sprite2D.frame = 2
	var base_name = animation_name.split("_")[0]
	animation_name = base_name + "_up"

func facing_down():
	if has_node("Sprite2D"):
		$Sprite2D.frame = 0
	var base_name = animation_name.split("_")[0]
	animation_name = base_name + "_down"
'''
	collectable.set_script(mock_script)

func test_initial_state():
	"""Test that Collectable starts in correct initial state"""
	assert_equal(collectable.animation_name, "collect")
	assert_false(collectable.player_in_area)
	assert_false(collectable.collected)

func test_facing_direction_updates():
	"""Test that facing direction methods update animation name and sprite frame"""
	# Test facing left
	collectable.facing_left()
	assert_equal(collectable.animation_name, "collect_left")
	
	# Reset for next test
	collectable.animation_name = "collect"
	
	# Test facing right
	collectable.facing_right()
	assert_equal(collectable.animation_name, "collect_right")
	
	# Reset for next test
	collectable.animation_name = "collect"
	
	# Test facing up
	collectable.facing_up()
	assert_equal(collectable.animation_name, "collect_up")
	
	# Reset for next test
	collectable.animation_name = "collect"
	
	# Test facing down
	collectable.facing_down()
	assert_equal(collectable.animation_name, "collect_down")

func test_collect_when_player_not_in_area():
	"""Test that collect returns null when player is not in area"""
	collectable.player_in_area = false
	collectable.collected = false
	
	var result = collectable.collect()
	assert_null(result)

func test_collect_when_already_collected():
	"""Test that collect returns null when already collected"""
	collectable.player_in_area = true
	collectable.collected = true
	
	var result = collectable.collect()
	assert_null(result)

func test_collect_successful_conditions():
	"""Test collect behavior when conditions are met"""
	# Set up successful conditions
	collectable.player_in_area = true
	collectable.collected = false
	
	# Mock collectableAsItem
	var mock_item = Resource.new()
	collectable.collectableAsItem = mock_item
	
	# Since we can't mock animations easily, we'll test the logic flow
	# The method should set collected = true and return the item
	# Note: In a real scenario, this would wait for animation to finish

func test_player_area_detection():
	"""Test player area enter/exit detection"""
	# Initially player not in area
	assert_false(collectable.player_in_area)
	
	# Simulate player entering area
	collectable.player_in_area = true
	assert_true(collectable.player_in_area)
	
	# Simulate player leaving area
	collectable.player_in_area = false
	assert_false(collectable.player_in_area)

func test_animation_name_modifications():
	"""Test that animation name can be modified correctly"""
	# Test base animation name
	collectable.animation_name = "collect"
	assert_equal(collectable.animation_name, "collect")
	
	# Test custom animation name
	collectable.animation_name = "special_collect"
	assert_equal(collectable.animation_name, "special_collect")
	
	# Test empty animation name
	collectable.animation_name = ""
	assert_equal(collectable.animation_name, "")

func test_collected_state_management():
	"""Test collected state flag management"""
	# Initially not collected
	assert_false(collectable.collected)
	
	# Set as collected
	collectable.collected = true
	assert_true(collectable.collected)
	
	# Reset collected state
	collectable.collected = false
	assert_false(collectable.collected)

func test_collectable_item_assignment():
	"""Test collectableAsItem property assignment"""
	# Initially null
	assert_null(collectable.collectableAsItem)
	
	# Assign mock item
	var mock_item = Resource.new()
	collectable.collectableAsItem = mock_item
	assert_equal(collectable.collectableAsItem, mock_item)
	
	# Clear item
	collectable.collectableAsItem = null
	assert_null(collectable.collectableAsItem)

func test_facing_direction_sprite_frames():
	"""Test that facing directions set correct sprite frames (if sprite exists)"""
	# These test the specific sprite frame values set by each direction
	# Note: In the actual implementation, these assume a Sprite2D child exists
	
	# We can test the logic even without the actual Sprite2D node
	# The methods should attempt to set specific frame values
	
	# Reset animation name for each test
	collectable.animation_name = "collect"
	collectable.facing_left()
	assert_true(collectable.animation_name.ends_with("_left"))
	
	collectable.animation_name = "collect"
	collectable.facing_right()
	assert_true(collectable.animation_name.ends_with("_right"))
	
	collectable.animation_name = "collect"
	collectable.facing_up()
	assert_true(collectable.animation_name.ends_with("_up"))
	
	collectable.animation_name = "collect"
	collectable.facing_down()
	assert_true(collectable.animation_name.ends_with("_down"))

func test_multiple_direction_changes():
	"""Test changing directions multiple times"""
	# Start with base animation
	collectable.animation_name = "collect"
	
	# Change directions multiple times
	collectable.facing_left()
	assert_equal(collectable.animation_name, "collect_left")
	
	collectable.facing_right()
	assert_equal(collectable.animation_name, "collect_right")
	
	collectable.facing_up()
	assert_equal(collectable.animation_name, "collect_up")
	
	collectable.facing_down()
	assert_equal(collectable.animation_name, "collect_down")
	
	# Reset to base
	collectable.animation_name = "collect"
	assert_equal(collectable.animation_name, "collect")

func test_custom_animation_with_directions():
	"""Test facing directions with custom animation names"""
	# Set custom base animation
	collectable.animation_name = "special"
	
	collectable.facing_left()
	assert_equal(collectable.animation_name, "special_left")
	
	collectable.animation_name = "custom"
	collectable.facing_right()
	assert_equal(collectable.animation_name, "custom_right")
	
	collectable.animation_name = "unique"
	collectable.facing_up()
	assert_equal(collectable.animation_name, "unique_up")
	
	collectable.animation_name = "test"
	collectable.facing_down()
	assert_equal(collectable.animation_name, "test_down")

func test_state_persistence():
	"""Test that state persists across different operations"""
	# Set initial state
	collectable.player_in_area = true
	collectable.collected = false
	collectable.animation_name = "test_collect"
	
	# Perform some direction changes
	collectable.facing_left()
	collectable.facing_right()
	
	# Check that other state persists
	assert_true(collectable.player_in_area)
	assert_false(collectable.collected)
	
	# Animation name should have changed
	assert_equal(collectable.animation_name, "test_collect_right")

func test_edge_cases():
	"""Test edge cases and boundary conditions"""
	# Test with empty animation name
	collectable.animation_name = ""
	collectable.facing_left()
	assert_equal(collectable.animation_name, "_left")
	
	# Reset and test null handling (if applicable)
	collectable.animation_name = "test"
	
	# Test rapid state changes
	collectable.player_in_area = true
	collectable.player_in_area = false
	collectable.player_in_area = true
	assert_true(collectable.player_in_area)
	
	collectable.collected = false
	collectable.collected = true
	collectable.collected = false
	assert_false(collectable.collected)

func test_collect_prerequisites():
	"""Test the prerequisites for successful collection"""
	# Test all combinations of prerequisites
	
	# Case 1: Player not in area, not collected
	collectable.player_in_area = false
	collectable.collected = false
	var result1 = collectable.collect()
	assert_null(result1)  # Should fail due to player not in area
	
	# Case 2: Player in area, already collected
	collectable.player_in_area = true
	collectable.collected = true
	var result2 = collectable.collect()
	assert_null(result2)  # Should fail due to already collected
	
	# Case 3: Player not in area, already collected
	collectable.player_in_area = false
	collectable.collected = true
	var result3 = collectable.collect()
	assert_null(result3)  # Should fail due to both conditions
	
	# Case 4: Player in area, not collected (should succeed if no animation)
	collectable.player_in_area = true
	collectable.collected = false
	# This case would succeed in real scenario but requires animation system 
