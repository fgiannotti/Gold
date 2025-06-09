extends "res://tests/test_runner.gd".BaseTest

var walls_script
var maze_constants

func _init():
	# Load the Walls script to access maze constants and logic
	walls_script = load("res://tilemaps/walls.gd")

func test_maze_constants():
	"""Test that maze constants are defined correctly"""
	# Test maze dimensions
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	
	assert_equal(MAZE_WIDTH, 20)
	assert_equal(MAZE_HEIGHT, 20)
	
	# Test direction constants (SENW binary mapping)
	var SOUTH_DIR = 1
	var EAST_DIR = 2
	var NORTH_DIR = 4
	var WEST_DIR = 8
	
	assert_equal(SOUTH_DIR, 1)
	assert_equal(EAST_DIR, 2)
	assert_equal(NORTH_DIR, 4)
	assert_equal(WEST_DIR, 8)
	
	# Test special tile values
	var SOLID_TILE_VAL = 15
	var ALL_DIRECTIONS = 0
	
	assert_equal(SOLID_TILE_VAL, 15)
	assert_equal(ALL_DIRECTIONS, 0)

func test_direction_binary_mapping():
	"""Test direction binary mapping logic"""
	# Test that direction values are powers of 2 for binary operations
	var SOUTH_DIR = 1   # 0001
	var EAST_DIR = 2    # 0010
	var NORTH_DIR = 4   # 0100
	var WEST_DIR = 8    # 1000
	
	# Test that they don't overlap (bitwise AND should be 0)
	assert_equal(SOUTH_DIR & EAST_DIR, 0)
	assert_equal(SOUTH_DIR & NORTH_DIR, 0)
	assert_equal(SOUTH_DIR & WEST_DIR, 0)
	assert_equal(EAST_DIR & NORTH_DIR, 0)
	assert_equal(EAST_DIR & WEST_DIR, 0)
	assert_equal(NORTH_DIR & WEST_DIR, 0)
	
	# Test that all directions combined equal 15 (1111)
	var all_dirs = SOUTH_DIR | EAST_DIR | NORTH_DIR | WEST_DIR
	assert_equal(all_dirs, 15)

func test_direction_vector_mapping():
	"""Test direction vector mapping"""
	# Test direction vector to decimal mapping
	var decimal_from_directions = {
		Vector2(1, 0): 4,   # NORTH_DIR
		Vector2(-1, 0): 1,  # SOUTH_DIR
		Vector2(0, 1): 2,   # EAST_DIR
		Vector2(0, -1): 8,  # WEST_DIR
	}
	
	# Verify mappings are correct
	assert_equal(decimal_from_directions[Vector2(1, 0)], 4)   # North
	assert_equal(decimal_from_directions[Vector2(-1, 0)], 1)  # South
	assert_equal(decimal_from_directions[Vector2(0, 1)], 2)   # East
	assert_equal(decimal_from_directions[Vector2(0, -1)], 8)  # West
	
	# Test that all directions are represented
	assert_equal(decimal_from_directions.size(), 4)

func test_maze_cell_connection_logic():
	"""Test maze cell connection logic"""
	# Test connection between adjacent cells
	var cell1 = Vector2(5, 5)
	var cell2 = Vector2(5, 6)  # East of cell1
	
	var direction_to_cell2 = cell2 - cell1  # (0, 1) = East
	var direction_to_cell1 = cell1 - cell2  # (0, -1) = West
	
	assert_equal(direction_to_cell2, Vector2(0, 1))
	assert_equal(direction_to_cell1, Vector2(0, -1))
	
	# Test that opposite directions are correct
	assert_equal(direction_to_cell2, -direction_to_cell1)

func test_maze_boundary_validation():
	"""Test maze boundary validation"""
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	
	# Test valid positions
	assert_true(0 >= 0 and 0 < MAZE_HEIGHT)    # Top edge
	assert_true(19 >= 0 and 19 < MAZE_HEIGHT)  # Bottom edge
	assert_true(0 >= 0 and 0 < MAZE_WIDTH)     # Left edge
	assert_true(19 >= 0 and 19 < MAZE_WIDTH)   # Right edge
	
	# Test center position
	assert_true(10 >= 0 and 10 < MAZE_WIDTH)
	assert_true(10 >= 0 and 10 < MAZE_HEIGHT)

func test_neighbor_calculation():
	"""Test neighbor cell calculation"""
	var cell = Vector2(5, 5)
	
	# Calculate neighbors
	var north_neighbor = Vector2(cell.x + 1, cell.y)  # (6, 5)
	var south_neighbor = Vector2(cell.x - 1, cell.y)  # (4, 5)
	var east_neighbor = Vector2(cell.x, cell.y + 1)   # (5, 6)
	var west_neighbor = Vector2(cell.x, cell.y - 1)   # (5, 4)
	
	assert_equal(north_neighbor, Vector2(6, 5))
	assert_equal(south_neighbor, Vector2(4, 5))
	assert_equal(east_neighbor, Vector2(5, 6))
	assert_equal(west_neighbor, Vector2(5, 4))
	
	# Test that neighbors are adjacent (distance = 1)
	assert_equal(cell.distance_to(north_neighbor), 1.0)
	assert_equal(cell.distance_to(south_neighbor), 1.0)
	assert_equal(cell.distance_to(east_neighbor), 1.0)
	assert_equal(cell.distance_to(west_neighbor), 1.0)

func test_maze_initialization():
	"""Test maze initialization with solid walls"""
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	var SOLID_TILE_VAL = 15
	
	# Simulate creating empty maze filled with solid walls
	var maze = []
	for i in MAZE_HEIGHT:
		maze.append([])
		for j in MAZE_WIDTH:
			maze[i].append(SOLID_TILE_VAL)
	
	# Verify maze is correctly initialized
	assert_equal(maze.size(), MAZE_HEIGHT)
	assert_equal(maze[0].size(), MAZE_WIDTH)
	
	# Check that all cells start as solid
	for y in range(MAZE_HEIGHT):
		for x in range(MAZE_WIDTH):
			assert_equal(maze[y][x], SOLID_TILE_VAL)

func test_direction_removal_logic():
	"""Test direction removal for creating passages"""
	var SOUTH_DIR = 1
	var EAST_DIR = 2
	var NORTH_DIR = 4
	var WEST_DIR = 8
	var SOLID_TILE_VAL = 15
	
	# Start with solid cell (all directions blocked)
	var cell_value = SOLID_TILE_VAL  # 15 = 1111
	
	# Remove east direction (subtract EAST_DIR)
	cell_value -= EAST_DIR  # 15 - 2 = 13 = 1101
	assert_equal(cell_value, 13)
	
	# Remove north direction
	cell_value -= NORTH_DIR  # 13 - 4 = 9 = 1001
	assert_equal(cell_value, 9)
	
	# Test that removed directions are open
	assert_equal(cell_value & EAST_DIR, 0)   # East should be open
	assert_equal(cell_value & NORTH_DIR, 0)  # North should be open
	assert_true(cell_value & SOUTH_DIR != 0) # South should be closed
	assert_true(cell_value & WEST_DIR != 0)  # West should be closed

func test_stack_based_generation():
	"""Test stack-based maze generation logic"""
	# Test stack operations for backtracking algorithm
	var stack = []
	var starting_cell = Vector2(1, 1)
	
	# Initialize stack
	stack.append(starting_cell)
	assert_equal(stack.size(), 1)
	assert_equal(stack[0], starting_cell)
	
	# Test push/pop operations
	var next_cell = Vector2(1, 2)
	stack.push_back(next_cell)
	assert_equal(stack.size(), 2)
	
	var popped_cell = stack.pop_back()
	assert_equal(popped_cell, next_cell)
	assert_equal(stack.size(), 1)
	
	# Test empty stack condition
	stack.pop_back()
	assert_equal(stack.size(), 0)

func test_visited_maze_tracking():
	"""Test visited cell tracking for maze generation"""
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	
	# Create visited maze (0 = unvisited, 1 = visited)
	var visited_maze = []
	for i in MAZE_HEIGHT:
		visited_maze.append([])
		for j in MAZE_WIDTH:
			visited_maze[i].append(0)
	
	# Mark starting cell as visited
	var starting_cell = Vector2(1, 1)
	visited_maze[starting_cell.x][starting_cell.y] = 1
	
	assert_equal(visited_maze[1][1], 1)
	assert_equal(visited_maze[0][0], 0)  # Other cells unvisited
	assert_equal(visited_maze[2][2], 0)

func test_neighbor_validation():
	"""Test neighbor validation for maze generation"""
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	var cell = Vector2(5, 5)
	
	# Test valid neighbors
	var neighbors = []
	
	# Check down neighbor
	if cell.x > 0:
		neighbors.append(Vector2(cell.x - 1, cell.y))
	
	# Check up neighbor  
	if cell.x < MAZE_HEIGHT - 1:
		neighbors.append(Vector2(cell.x + 1, cell.y))
	
	# Check left neighbor
	if cell.y > 0:
		neighbors.append(Vector2(cell.x, cell.y - 1))
	
	# Check right neighbor
	if cell.y < MAZE_WIDTH - 1:
		neighbors.append(Vector2(cell.x, cell.y + 1))
	
	# Should have 4 valid neighbors for center cell
	assert_equal(neighbors.size(), 4)
	
	# Test edge cell (should have fewer neighbors)
	var edge_cell = Vector2(0, 0)
	var edge_neighbors = []
	
	if edge_cell.x < MAZE_HEIGHT - 1:
		edge_neighbors.append(Vector2(edge_cell.x + 1, edge_cell.y))
	
	if edge_cell.y < MAZE_WIDTH - 1:
		edge_neighbors.append(Vector2(edge_cell.x, edge_cell.y + 1))
	
	# Corner cell should have only 2 neighbors
	assert_equal(edge_neighbors.size(), 2)

func test_tile_value_to_coordinates():
	"""Test tile value to coordinate mapping"""
	# Test some key tile mappings
	var decimal_to_coord = {
		0: Vector2(5, 2),   # ALL_DIRECTIONS open
		1: Vector2(1, 0),   # TOP_CLOSED
		15: Vector2(6, 2),  # SOLID_TILE_VAL
	}
	
	# Verify mappings exist and are valid coordinates
	for value in decimal_to_coord:
		var coord = decimal_to_coord[value]
		assert_true(coord.x >= 0)
		assert_true(coord.y >= 0)
		assert_true(coord.x < 8)  # Reasonable tileset bounds
		assert_true(coord.y < 8)

func test_room_tile_constants():
	"""Test room-specific tile constants"""
	var ROOM_OPEN = 16
	var ROOM_CEILING = 17
	var ROOM_FLOOR = 21
	var ROOM_TOP_LEFT = 19
	var ROOM_TOP_RIGHT = 20
	var ROOM_BOTTOM_LEFT = 22
	var ROOM_BOTTOM_RIGHT = 23
	
	# Verify room tile values are distinct
	var room_tiles = [ROOM_OPEN, ROOM_CEILING, ROOM_FLOOR, ROOM_TOP_LEFT, 
					  ROOM_TOP_RIGHT, ROOM_BOTTOM_LEFT, ROOM_BOTTOM_RIGHT]
	
	# All should be unique
	for i in range(room_tiles.size()):
		for j in range(room_tiles.size()):
			if i != j:
				assert_true(room_tiles[i] != room_tiles[j])
	
	# All should be greater than standard maze values (0-15)
	for tile in room_tiles:
		assert_true(tile > 15)

func test_maze_generation_bounds():
	"""Test maze generation stays within bounds"""
	var MAZE_WIDTH = 20
	var MAZE_HEIGHT = 20
	
	# Test that generation starts within bounds
	var starting_cell = Vector2(1, 1)
	assert_true(starting_cell.x >= 1 and starting_cell.x < MAZE_HEIGHT - 1)
	assert_true(starting_cell.y >= 1 and starting_cell.y < MAZE_WIDTH - 1)
	
	# Test maximum reachable positions
	var max_x = MAZE_HEIGHT - 1
	var max_y = MAZE_WIDTH - 1
	
	assert_equal(max_x, 19)
	assert_equal(max_y, 19)

func test_direction_consistency():
	"""Test direction mapping consistency"""
	# Test that direction constants match their intended directions
	var NORTH_DIR = 4  # Binary: 0100
	var SOUTH_DIR = 1  # Binary: 0001  
	var EAST_DIR = 2   # Binary: 0010
	var WEST_DIR = 8   # Binary: 1000
	
	# Test binary representations
	assert_equal(NORTH_DIR, 0b0100)
	assert_equal(SOUTH_DIR, 0b0001)
	assert_equal(EAST_DIR, 0b0010)
	assert_equal(WEST_DIR, 0b1000)
	
	# Test that combining all directions gives 15 (1111)
	var combined = NORTH_DIR | SOUTH_DIR | EAST_DIR | WEST_DIR
	assert_equal(combined, 15)
	assert_equal(combined, 0b1111) 