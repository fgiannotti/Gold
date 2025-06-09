extends SceneTree

# Test Runner - Execute all tests without running the main game
# Usage: godot --script tests/test_runner.gd

var test_results = []
var total_tests = 0
var passed_tests = 0
var failed_tests = 0
var current_test_failed = false
var current_test_error = ""

func _init():
	print("🧪 Starting Gold Game Test Suite")
	print(repeat_string("=", 50))
	
	run_all_tests()
	
	print_summary()
	# Exit codes are now handled in print_summary()

func repeat_string(text: String, count: int) -> String:
	var result = ""
	for i in range(count):
		result += text
	return result

func run_all_tests():
	# Basic Framework Test (no dependencies)
	run_test_suite("Basic Framework Tests", "res://tests/test_basic.gd")
	
	# Core Systems Tests
	run_test_suite("GameStats Tests", "res://tests/test_game_stats.gd")
	run_test_suite("PlayerManager Tests", "res://tests/test_player_manager.gd")
	run_test_suite("MetaGame Tests", "res://tests/test_meta_game.gd")
	
	# Collectables Tests
	run_test_suite("BreakableConfig Tests", "res://tests/test_breakable_config.gd")
	run_test_suite("Collectable Tests", "res://tests/test_collectable.gd")
	
	# World Generation Tests  
	run_test_suite("Maze Tests", "res://tests/test_maze.gd")
	
	# Utility Tests
	run_test_suite("Data Validation Tests", "res://tests/test_data_validation.gd")

func run_test_suite(suite_name: String, script_path: String):
	print("\n📋 Running: " + suite_name)
	print(repeat_string("-", 30))
	
	# Try to load and instantiate the test script
	var test_script = load(script_path)
	if test_script == null:
		print("❌ Failed to load test script: " + script_path)
		return
	
	var test_instance = test_script.new()
	if test_instance == null:
		print("❌ Failed to create test instance from: " + script_path)
		return
	
	# Set the test runner reference safely
	if test_instance.has_method("set_test_runner"):
		test_instance.set_test_runner(self)
	elif "test_runner" in test_instance:
		test_instance.test_runner = self
	else:
		print("⚠️ Warning: Test instance doesn't have test_runner property")
	
	var methods = test_instance.get_method_list()
	var suite_passed = 0
	var suite_failed = 0
	
	for method in methods:
		if method.name.begins_with("test_"):
			total_tests += 1
			var test_name = method.name.replace("test_", "").replace("_", " ").capitalize()
			
			# Reset test state
			current_test_failed = false
			current_test_error = ""
			
			# Try to call the test method with error handling
			if test_instance.has_method(method.name):
				try_run_test(test_instance, method.name, test_name)
				
				# Check if test failed
				if current_test_failed:
					print("❌ " + test_name + " - " + current_test_error)
					failed_tests += 1
					suite_failed += 1
				else:
					print("✅ " + test_name)
					passed_tests += 1
					suite_passed += 1
			else:
				print("❌ " + test_name + " - Method not found")
				failed_tests += 1
				suite_failed += 1
	
	if suite_passed + suite_failed == 0:
		print("⚠️ No test methods found in this suite")
	else:
		print("Suite Summary: %d passed, %d failed" % [suite_passed, suite_failed])

func try_run_test(test_instance, method_name: String, test_name: String):
	# Call the test method directly - GDScript doesn't have try/except
	test_instance.call(method_name)

func mark_test_failed(error_message: String):
	current_test_failed = true
	current_test_error = error_message

func print_summary():
	print("\n" + repeat_string("=", 50))
	print("🎯 TEST SUMMARY")
	print("Total Tests: %d" % total_tests)
	print("✅ Passed: %d" % passed_tests)
	print("❌ Failed: %d" % failed_tests)
	
	var success_rate = (float(passed_tests) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0
	print("Success Rate: %.1f%%" % success_rate)
	
	if failed_tests == 0:
		print("🎉 All tests passed!")
		# Exit with success code for CI/CD
		get_tree().quit(0)
	else:
		print("⚠️  Some tests failed. Please review.")
		# Exit with failure code for CI/CD
		get_tree().quit(1)

# Base Test Class
class BaseTest:
	var test_runner = null
	
	func set_test_runner(runner):
		test_runner = runner
	
	func assert_equal(actual, expected, message = ""):
		if actual != expected:
			var error_msg = "Expected: %s, Got: %s" % [str(expected), str(actual)]
			if message != "":
				error_msg += " - " + message
			if test_runner:
				test_runner.mark_test_failed(error_msg)
			else:
				print("TEST FAILED: " + error_msg)
	
	func assert_true(condition, message = ""):
		if not condition:
			var error_msg = "Expected true" + (" - " + message if message != "" else "")
			if test_runner:
				test_runner.mark_test_failed(error_msg)
			else:
				print("TEST FAILED: " + error_msg)
	
	func assert_false(condition, message = ""):
		if condition:
			var error_msg = "Expected false" + (" - " + message if message != "" else "")
			if test_runner:
				test_runner.mark_test_failed(error_msg)
			else:
				print("TEST FAILED: " + error_msg)
	
	func assert_not_null(value, message = ""):
		if value == null:
			var error_msg = "Expected non-null value" + (" - " + message if message != "" else "")
			if test_runner:
				test_runner.mark_test_failed(error_msg)
			else:
				print("TEST FAILED: " + error_msg)
	
	func assert_null(value, message = ""):
		if value != null:
			var error_msg = "Expected null value" + (" - " + message if message != "" else "")
			if test_runner:
				test_runner.mark_test_failed(error_msg)
			else:
				print("TEST FAILED: " + error_msg)

# Test Classes Import 