extends "res://tests/test_runner.gd".BaseTest

func test_basic_assertions():
	"""Test that basic assertions work"""
	assert_equal(1, 1)
	assert_equal("hello", "hello")
	assert_true(true)
	assert_false(false)
	assert_not_null("not null")
	assert_null(null)

func test_math_operations():
	"""Test basic math operations"""
	assert_equal(2 + 2, 4)
	assert_equal(5 * 3, 15)
	assert_equal(10 - 3, 7)
	assert_equal(8 / 2, 4)

func test_string_operations():
	"""Test string operations"""
	var str1 = "Hello"
	var str2 = "World"
	assert_equal(str1 + " " + str2, "Hello World")
	assert_true(str1.length() > 0)
	assert_equal(str1.to_upper(), "HELLO")

func test_array_operations():
	"""Test array operations"""
	var arr = [1, 2, 3]
	assert_equal(arr.size(), 3)
	assert_equal(arr[0], 1)
	assert_equal(arr[2], 3)
	
	arr.append(4)
	assert_equal(arr.size(), 4)
	assert_equal(arr[3], 4) 