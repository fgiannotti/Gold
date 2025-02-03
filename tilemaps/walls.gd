extends TileMapLayer

signal stair_decided(stair_position_in_world)

const MAZE_WIDTH = 20
const MAZE_HEIGHT = 20 # counting from 0

# values set from binary mapping
const NORTH_DIR = 4
const SOUTH_DIR = 1
const EAST_DIR = 2
const WEST_DIR = 8

var decimal_from_directions = {
	Vector2(1, 0): NORTH_DIR,
	Vector2(-1, 0): SOUTH_DIR,
	Vector2(0, 1): EAST_DIR,
	Vector2(0, -1): WEST_DIR,
}
const SOLID_TILE_VAL = 15
# Room tiles
const STAIR_DOWN = 31
const ROOM_OPEN = 16
const ROOM_CEILING = 17
const ROOM_FLOOR = 21

const ROOM_TOP_LEFT = 19
const ROOM_TOP_RIGHT = 20
const ROOM_BOTTOM_LEFT = 22
const ROOM_BOTTOM_RIGHT = 23

const ROOM_LEFT_WALL = 24
const ROOM_RIGHT_WALL = 25

const ROOM_LEFT_GATE = 26
const ROOM_RIGHT_GATE = 27
const ROOM_TOP_GATE = 28
const ROOM_BOTTOM_GATE = 29

const ALL_DIRECTIONS = 0
const DOWN_CLOSED = 4
const TOP_CLOSED = 1
const LEFT_CLOSED = 8
const RIGHT_CLOSED = 2

@export var enemy_spawner: EnemySpawner

var positions_open_room: Array = []

# Map decimals to TileSet
var decimal_to_cord = {

	ALL_DIRECTIONS: Vector2(5, 2),
	TOP_CLOSED: Vector2(1, 0),
	LEFT_CLOSED: Vector2(5, 1),
	3: Vector2(2, 2),
	DOWN_CLOSED: Vector2(7, 1),
	5: Vector2(4, 3),
	6: Vector2(7, 0),
	7: Vector2(4, 1),
	RIGHT_CLOSED: Vector2(4, 2),
	9: Vector2(0, 0),
	10: Vector2(6, 0),
	11: Vector2(1, 2),
	12: Vector2(6, 1),
	13: Vector2(5, 0),
	14: Vector2(0, 3),
	SOLID_TILE_VAL: Vector2(6, 2),
	
	# Room Mapping
	STAIR_DOWN: Vector2(6, 4),
	ROOM_OPEN: Vector2(5, 3),
	ROOM_CEILING: Vector2(2, 0),
	ROOM_TOP_LEFT: Vector2(2, 1),
	ROOM_TOP_RIGHT: Vector2(3, 0),
	
	ROOM_FLOOR: Vector2(0, 1),
	ROOM_BOTTOM_LEFT: Vector2(2, 3),
	ROOM_BOTTOM_RIGHT: Vector2(3, 2),
	
	ROOM_LEFT_WALL: Vector2(1, 3),
	ROOM_RIGHT_WALL: Vector2(1, 1),
	
	ROOM_LEFT_GATE: Vector2(0, 2),
	ROOM_RIGHT_GATE: Vector2(3, 1),
	ROOM_TOP_GATE: Vector2(3, 3),
	ROOM_BOTTOM_GATE: Vector2(4, 0)
	
}

const SOURCE_ID = 0 # Tileset atlas, only 1
const DEBUG_MAZE = false
var stair_position_in_world: Vector2
var stair_position_in_tilemap: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	var maze: Array = generate_maze()
	# Add some start/finish:
	# await connect_cell_with_nghbr(maze, Vector2(0,1), Vector2(1,1))
	# await connect_cell_with_nghbr(maze, Vector2(7,6), Vector2(6,6))
	
	# Set tile 
	for y in maze.size():
		for x in maze[y].size():
			set_cell(Vector2i(x, y), SOURCE_ID, decimal_to_cord[maze[y][x]], 0)
	for room in rooms:
		set_cell(Vector2i(room.top_gate.y, room.top_gate.x), SOURCE_ID, decimal_to_cord[ROOM_TOP_GATE], 0)
		set_cell(Vector2i(room.bottom_gate.y, room.bottom_gate.x), SOURCE_ID, decimal_to_cord[ROOM_BOTTOM_GATE], 0)
		set_cell(Vector2i(room.right_gate.y, room.right_gate.x), SOURCE_ID, decimal_to_cord[ROOM_RIGHT_GATE], 0)
		set_cell(Vector2i(room.left_gate.y, room.left_gate.x), SOURCE_ID, decimal_to_cord[ROOM_LEFT_GATE], 0)

	stair_position_in_world = self.map_to_local(stair_position_in_tilemap)
	emit_signal("stair_decided", stair_position_in_world)
	
	enemy_spawner.spawn_enemies(positions_open_room, 50)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var stack = []
var rooms: Array = []
func generate_maze():
	# Initialize maze and extra maze
	var maze: Array = empty_maze(SOLID_TILE_VAL)
	var visited_maze: Array = empty_maze(0)
	var starting_cell = Vector2(1, 1)
	print(maze)
	visited_maze[starting_cell.x][starting_cell.y] = 1
	stack.append(starting_cell)
	print('Executing maze build')

	place_rooms(maze, visited_maze)
	place_borders(visited_maze)
	build_with_backtracking(maze, visited_maze)
	print('returning maze...', maze)
	return maze

func build_with_backtracking(maze, visited_maze):
	var cell: Vector2
	while stack.size() > 0:
		if DEBUG_MAZE:
			print('-----------')
			print('Iterating with cell: ', cell, ' and stack: ', stack)

		cell = stack.pop_back()
		var neighbors: Array = []
		if cell.x > 0:
			# Down Neighbor visited?
			if visited_maze[cell.x - 1][cell.y] == 0:
				neighbors.append(Vector2(cell.x - 1, cell.y))
		if cell.x < MAZE_HEIGHT - 1:
			# Top Neighbor visited?
			if visited_maze[cell.x + 1][cell.y] == 0:
				neighbors.append(Vector2(cell.x + 1, cell.y))
		if cell.y > 0:
			# Right Neighbor visited?
			if visited_maze[cell.x][cell.y - 1] == 0:
				neighbors.append(Vector2(cell.x, cell.y - 1))
		if cell.y < MAZE_WIDTH - 1:
			# Left Neighbor visited?
			if visited_maze[cell.x][cell.y + 1] == 0:
				neighbors.append(Vector2(cell.x, cell.y + 1))
		#print('For cell:', cell, ' obtained neighbors unvisited: ', neighbors)
		
		if neighbors.size() > 0:
			stack.push_back(cell)
			var rnd_neighbr: int = RandomNumberGenerator.new().randi_range(0, neighbors.size() - 1)
			var chosen_nghbr: Vector2 = neighbors[rnd_neighbr]
			connect_cell_with_nghbr(maze, cell, chosen_nghbr)

			if DEBUG_MAZE:
				print('From cell:', cell, ' value: ', maze[cell.x][cell.y], ' chosen neighbor: ', chosen_nghbr, '  neighbors: ', neighbors, ' with value: ', maze[chosen_nghbr.x][chosen_nghbr.y])
				print('maze so far...')
				print(maze)

			visited_maze[chosen_nghbr.x][chosen_nghbr.y] = 1
			stack.push_back(chosen_nghbr)

func connect_cell_with_nghbr(maze, cell, nghbr_cell):
	# Create the path
	var direction_to_open_cell_pov: Vector2 = nghbr_cell - cell # 1,2 - 1,1 = 0,1
	var direction_to_open_nghbr_pov: Vector2 = cell - nghbr_cell # 1,1 - 1,2 = 0,-1

	#print('direction ', direction, ' decimal obtained: ', decimal_from_directions[direction])
	maze[cell.x][cell.y] -= decimal_from_directions[direction_to_open_cell_pov]
	maze[nghbr_cell.x][nghbr_cell.y] -= decimal_from_directions[direction_to_open_nghbr_pov]
	if maze[cell.x][cell.y] < 0 or maze[nghbr_cell.x][nghbr_cell.y] < 0:
		var cell_val = maze[cell.x][cell.y]
		var nghbr_cell_val = maze[nghbr_cell.x][nghbr_cell.y]
		var prev_nghbr_cell_val = maze[nghbr_cell.x][nghbr_cell.y] + decimal_from_directions[direction_to_open_nghbr_pov]
		print('reporting invalid cell operation. Cell: ', cell, ' with value:', cell_val, 'neighbor_cell: ', nghbr_cell, 'with value: ', nghbr_cell_val)

func empty_maze(val: int):
	var maze: Array = []
	for i in MAZE_HEIGHT:
		maze.append([])
		for j in MAZE_WIDTH:
			maze[i].append(val)
	return maze

# Initialize maze with all solid values
# Initialize mask maze for visited values
# Place rooms 
	# Put borders
	# Leave middle as free values
func chose_room_for_stairs(rooms: Array):
	var room = rooms.pick_random()
	room.has_stair = true

func place_rooms(maze: Array, visited_maze: Array):
	var position1 = Vector2(MAZE_WIDTH / 8, MAZE_HEIGHT / 8)
	var position2 = Vector2(round(5 * MAZE_WIDTH / 8), round(MAZE_HEIGHT / 8))
	var position3 = Vector2(round(MAZE_WIDTH / 8), round(5 * MAZE_HEIGHT / 8))
	var position4 = Vector2(round(5 * MAZE_WIDTH / 8), round(5 * MAZE_HEIGHT / 8))
	
	
	var room1: Room = Room.new(position1)
	var room2: Room = Room.new(position2)
	var room3: Room = Room.new(position3)
	var room4: Room = Room.new(position4)
	var rooms: Array[Room] = [room1, room2, room3, room4]
	chose_room_for_stairs(rooms);
	# Place borders
	fill_maze_from_room(maze, visited_maze, room1)
	fill_maze_from_room(maze, visited_maze, room2)
	fill_maze_from_room(maze, visited_maze, room3)
	fill_maze_from_room(maze, visited_maze, room4)
# j == x
# i == y

func fill_maze_from_room(maze, visited_maze, room1):
	var height_line_finish: float = room1.height_line_finish
	var width_line_finish: float = room1.width_line_finish
	
	print("width_line_finish ", width_line_finish, " position_x ", room1.position.x)
	print("height_line_finish ", height_line_finish, " position_y ", room1.position.y)
	maze[room1.position.y][room1.position.x] = ROOM_TOP_LEFT
	maze[room1.position.y][width_line_finish] = ROOM_TOP_RIGHT
	maze[height_line_finish][room1.position.x] = ROOM_BOTTOM_LEFT
	maze[height_line_finish][width_line_finish] = ROOM_BOTTOM_RIGHT

	# Left/Right Borders
	for y in range(room1.position.y + 1, height_line_finish):
		maze[y][room1.position.x] = ROOM_LEFT_WALL
		maze[y][width_line_finish] = ROOM_RIGHT_WALL
		
	for x in range(room1.position.x + 1, width_line_finish):
		maze[room1.position.y][x] = ROOM_CEILING
		maze[height_line_finish][x] = ROOM_FLOOR
	
	
	for x in range(room1.position.x + 1, width_line_finish):
		for y in range(room1.position.y + 1, height_line_finish):
				maze[y][x] = ROOM_OPEN
				positions_open_room.append(self.map_to_local(Vector2(x,y)))
	#assign stair
	if (room1.has_stair):
		var rng = RandomNumberGenerator.new()
		var int_random_x = rng.randi_range(room1.position.x + 1, width_line_finish - 1)
		var int_random_y = rng.randi_range(room1.position.y + 1, height_line_finish - 1)
		#maze[intRandomY][intRandomX] = STAIR_DOWN
		#Antes la Linea de arriba ponia la escalera desde el Tile Set
		stair_position_in_tilemap = Vector2(int_random_x, int_random_y)
		print('######### Spawn Stair ###############', stair_position_in_tilemap)

	# print("iterating to fill gates for room...")
	for x in range(room1.position.x, width_line_finish + 1):
		for y in range(room1.position.y, height_line_finish + 1):
			visited_maze[y][x] = 1
			var cell = Vector2(y, x)
			if cell == room1.top_gate:
				# print('setting top room door as unvisited ', x, y)
				visited_maze[y][x] = 0
				maze[y][x] = TOP_CLOSED
			if cell == room1.bottom_gate:
				# print('setting bottom room door as unvisited ', x, y)
				visited_maze[y][x] = 0
				maze[y][x] = DOWN_CLOSED
			if cell == room1.left_gate:
				# print('setting left room door as unvisited ', x, y)
				visited_maze[y][x] = 0
				maze[y][x] = LEFT_CLOSED
			if cell == room1.right_gate:
				# print('setting right room door as unvisited ', x, y)
				visited_maze[y][x] = 0
				maze[y][x] = RIGHT_CLOSED
	rooms.append(room1)

func place_borders(visited_maze):
	# techito
	for j in MAZE_WIDTH:
		visited_maze[0][j] = 1
	# piso
	for j in MAZE_WIDTH:
		visited_maze[-1][j] = 1
	# pared der
	for i in MAZE_HEIGHT:
		visited_maze[i][-1] = 1
	# pared izq
	for i in MAZE_HEIGHT:
		visited_maze[i][0] = 1

const ROOM_AMOUNT = 1

class Room:
	var dimension: Vector2
	var position: Vector2 # its first top left tile
	var room_tiles: Array
	var height_line_finish: float
	var width_line_finish: float
	var has_stair: bool = false
	
	var left_gate: Vector2
	var right_gate: Vector2
	var bottom_gate: Vector2
	var top_gate: Vector2

	# HEIGHT == first index
	func _init(position: Vector2):
		# MAX is W/2, H/2
		self.dimension = Vector2(
			RandomNumberGenerator.new().randi_range(3, 7),
			RandomNumberGenerator.new().randi_range(3, 7),
			)
		self.position = position
		
		var width_line_finish_aux = self.position.x + self.dimension.x
		if width_line_finish_aux >= MAZE_WIDTH:
			print('[room] dimension too wide', self.position)
			self.dimension.x -= (width_line_finish_aux - MAZE_WIDTH + 1)
			
		self.width_line_finish = self.position.x + self.dimension.x

		var height_line_finish_aux = self.position.y + self.dimension.y
		if height_line_finish_aux >= MAZE_HEIGHT:
			print('[room] dimension too high', self.position)
			self.dimension.y -= (height_line_finish_aux - MAZE_HEIGHT + 1)
			
		self.height_line_finish = self.position.y + self.dimension.y
		

		self.left_gate = Vector2(round((self.position.y + self.height_line_finish + 1) / 2), self.position.x)
		if (self.left_gate.y == 0):
			self.left_gate = Vector2(-1, -1)
		self.right_gate = Vector2(round((self.position.y + self.height_line_finish + 1) / 2), self.width_line_finish)
		if (self.right_gate.y >= MAZE_WIDTH - 2):
			self.right_gate = Vector2(-1, -1)
		self.top_gate = Vector2(self.position.y, round((self.position.x + self.width_line_finish + 1) / 2))
		if (self.top_gate.x == 0):
			self.top_gate = Vector2(-1, -1)
		self.bottom_gate = Vector2(self.height_line_finish, round((self.position.x + self.width_line_finish + 1) / 2))
		if (self.bottom_gate.x >= MAZE_HEIGHT - 2):
			self.bottom_gate = Vector2(-1, -1)
		print("left_gate ", left_gate)
		print("right_gate ", right_gate)
		print("bottom_gate ", bottom_gate)
		print("top_gate ", top_gate)
		for x in range(self.position.x, width_line_finish + 1):
			for y in range(self.position.y, height_line_finish + 1):
				room_tiles.append(Vector2(y, x))


func restart_maze() -> void:
	self.clear()
	rooms = []
	_ready() # Regenerate maze
