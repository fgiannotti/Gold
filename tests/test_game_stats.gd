extends "res://tests/test_runner.gd".BaseTest

var game_stats: Node

func _init():
	# Create a mock GameStats node for testing
	game_stats = Node.new()
	game_stats.set_script(load("res://screens/game_stats.gd"))

func test_initial_stats_are_zero():
	"""Test that all stats start at zero"""
	game_stats.reset_stats()
	
	assert_equal(game_stats.get_stat("breakables_destroyed"), 0)
	assert_equal(game_stats.get_stat("minerals_mined"), 0)
	assert_equal(game_stats.get_stat("enemies_defeated"), 0)
	assert_equal(game_stats.get_stat("damage_taken"), 0)
	assert_equal(game_stats.get_stat("healing_received"), 0)
	assert_equal(game_stats.get_stat("items_collected"), 0)
	assert_equal(game_stats.get_stat("chests_opened"), 0)
	assert_equal(game_stats.get_stat("deaths"), 0)
	assert_equal(game_stats.get_stat("wins"), 0)

func test_increment_stat_basic():
	"""Test basic stat incrementation"""
	game_stats.reset_stats()
	
	game_stats.increment_stat("breakables_destroyed")
	assert_equal(game_stats.get_stat("breakables_destroyed"), 1)
	
	game_stats.increment_stat("breakables_destroyed")
	assert_equal(game_stats.get_stat("breakables_destroyed"), 2)

func test_increment_stat_with_amount():
	"""Test stat incrementation with custom amounts"""
	game_stats.reset_stats()
	
	game_stats.increment_stat("damage_taken", 25)
	assert_equal(game_stats.get_stat("damage_taken"), 25)
	
	game_stats.increment_stat("damage_taken", 10)
	assert_equal(game_stats.get_stat("damage_taken"), 35)

func test_convenience_functions():
	"""Test the convenience wrapper functions"""
	game_stats.reset_stats()
	
	# Test breakable destroyed
	game_stats.breakable_destroyed()
	assert_equal(game_stats.get_stat("breakables_destroyed"), 1)
	
	# Test mineral mined
	game_stats.mineral_mined()
	assert_equal(game_stats.get_stat("minerals_mined"), 1)
	
	# Test enemy defeated
	game_stats.enemy_defeated()
	assert_equal(game_stats.get_stat("enemies_defeated"), 1)
	
	# Test damage taken
	game_stats.damage_taken(50)
	assert_equal(game_stats.get_stat("damage_taken"), 50)
	
	# Test healing received
	game_stats.healing_received(30)
	assert_equal(game_stats.get_stat("healing_received"), 30)
	
	# Test item collected
	game_stats.item_collected()
	assert_equal(game_stats.get_stat("items_collected"), 1)
	
	# Test chest opened
	game_stats.chest_opened()
	assert_equal(game_stats.get_stat("chests_opened"), 1)
	
	# Test player died
	game_stats.player_died()
	assert_equal(game_stats.get_stat("deaths"), 1)
	
	# Test player won
	game_stats.player_won()
	assert_equal(game_stats.get_stat("wins"), 1)

func test_invalid_stat_name():
	"""Test handling of invalid stat names"""
	game_stats.reset_stats()
	
	# Should return 0 for non-existent stats
	assert_equal(game_stats.get_stat("invalid_stat"), 0)
	
	# Incrementing invalid stat should not crash
	game_stats.increment_stat("invalid_stat", 5)
	# Should still return 0 since stat doesn't exist
	assert_equal(game_stats.get_stat("invalid_stat"), 0)

func test_get_all_stats():
	"""Test getting all stats as a dictionary"""
	game_stats.reset_stats()
	
	# Add some test data
	game_stats.increment_stat("breakables_destroyed", 5)
	game_stats.increment_stat("minerals_mined", 3)
	game_stats.increment_stat("enemies_defeated", 2)
	
	var all_stats = game_stats.get_all_stats()
	
	# Verify it's a dictionary with expected values
	assert_equal(all_stats["breakables_destroyed"], 5)
	assert_equal(all_stats["minerals_mined"], 3)
	assert_equal(all_stats["enemies_defeated"], 2)
	assert_equal(all_stats["damage_taken"], 0)
	assert_equal(all_stats["healing_received"], 0)
	assert_equal(all_stats["items_collected"], 0)
	assert_equal(all_stats["chests_opened"], 0)
	assert_equal(all_stats["deaths"], 0)
	assert_equal(all_stats["wins"], 0)

func test_reset_stats():
	"""Test that reset_stats properly zeros all values"""
	# Set some values
	game_stats.increment_stat("breakables_destroyed", 10)
	game_stats.increment_stat("damage_taken", 100)
	game_stats.increment_stat("wins", 1)
	
	# Verify they're set
	assert_equal(game_stats.get_stat("breakables_destroyed"), 10)
	assert_equal(game_stats.get_stat("damage_taken"), 100)
	assert_equal(game_stats.get_stat("wins"), 1)
	
	# Reset and verify all are zero
	game_stats.reset_stats()
	assert_equal(game_stats.get_stat("breakables_destroyed"), 0)
	assert_equal(game_stats.get_stat("damage_taken"), 0)
	assert_equal(game_stats.get_stat("wins"), 0)

func test_stats_persistence_across_operations():
	"""Test that stats maintain their values across multiple operations"""
	game_stats.reset_stats()
	
	# Simulate a game session
	game_stats.breakable_destroyed()
	game_stats.breakable_destroyed()
	game_stats.mineral_mined()
	game_stats.enemy_defeated()
	game_stats.damage_taken(25)
	game_stats.healing_received(15)
	game_stats.item_collected()
	game_stats.chest_opened()
	
	# Verify all values are correct
	assert_equal(game_stats.get_stat("breakables_destroyed"), 2)
	assert_equal(game_stats.get_stat("minerals_mined"), 1)
	assert_equal(game_stats.get_stat("enemies_defeated"), 1)
	assert_equal(game_stats.get_stat("damage_taken"), 25)
	assert_equal(game_stats.get_stat("healing_received"), 15)
	assert_equal(game_stats.get_stat("items_collected"), 1)
	assert_equal(game_stats.get_stat("chests_opened"), 1)
	assert_equal(game_stats.get_stat("deaths"), 0)
	assert_equal(game_stats.get_stat("wins"), 0) 