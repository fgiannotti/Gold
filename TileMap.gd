extends TileMap

const MAZE_WIDTH =  20
const MAZE_HEIGHT = 20  # counting from 0

# values set from binary mapping
const NORTH_DIR = 4
const SOUTH_DIR = 1
const EAST_DIR = 2
const WEST_DIR = 8
var decimal_from_directions = {
	Vector2(1,0): NORTH_DIR,
	Vector2(-1,0): SOUTH_DIR,
	Vector2(0,1): EAST_DIR,
	Vector2(0,-1): WEST_DIR,
}

var decimal_to_cord = {
	0: Vector2(5,2),
	1: Vector2(1,0),
	2: Vector2(4,2),
	3: Vector2(2,2),
	4: Vector2(7,1),
	5: Vector2(4,3),
	6: Vector2(7,0),
	7: Vector2(4,1),
	8: Vector2(5,1),
	9: Vector2(0,0),
	10: Vector2(6,0),
	11: Vector2(1,2),
	12: Vector2(6,1),
	13: Vector2(5,0),
	14: Vector2(0,3),
	15: Vector2(6,3),
}
const decimal_max: int = 15 # 0 to 15 are the possibles decimal values of the tile set
const SOURCE_ID = 0 # Tileset atlas, only 1
const DEBUG_MAZE = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var maze: Array = generate_maze()
	await connect_cell_with_nghbr(maze, Vector2(0,1), Vector2(1,1))
	await connect_cell_with_nghbr(maze, Vector2(7,6), Vector2(6,6))
	
	for i in maze.size():
		for j in maze[i].size():
			set_cell(0, Vector2i(i,j), SOURCE_ID,decimal_to_cord[maze[j][i]],0) # FLIP INDEX BECAUSE X axis is my J index and viceversa
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var stack = []
func generate_maze():
	var maze: Array = empty_maze(15)
	var visited_maze: Array = empty_maze(0)
	var starting_cell = Vector2(1,1)
	print(maze)
	visited_maze[starting_cell.x][starting_cell.y] = 1
	stack.append(starting_cell)
	print('Executing maze build')
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
			if visited_maze[cell.x-1][cell.y] == 0:
				neighbors.append(Vector2(cell.x-1,cell.y))
		if cell.x < MAZE_HEIGHT-1:
			if visited_maze[cell.x+1][cell.y] == 0:
				neighbors.append(Vector2(cell.x+1,cell.y))
		if cell.y > 0:
			if visited_maze[cell.x][cell.y-1] == 0:
				neighbors.append(Vector2(cell.x,cell.y-1))
		if cell.y < MAZE_WIDTH-1:
			if visited_maze[cell.x][cell.y+1] == 0:
				neighbors.append(Vector2(cell.x,cell.y+1))
		#print('For cell:', cell, ' obtained neighbors unvisited: ', neighbors)
		
		if neighbors.size() > 0:
			stack.push_back(cell)
			var rnd_neighbr: int = RandomNumberGenerator.new().randi_range(0,neighbors.size()-1)
			var chosen_nghbr: Vector2 = neighbors[rnd_neighbr]
			connect_cell_with_nghbr(maze, cell, chosen_nghbr)

			if DEBUG_MAZE:
				print('From cell:', cell, ' value: ',maze[cell.x][cell.y] ,' chosen neighbor: ', chosen_nghbr, '  neighbors: ', neighbors,' with value: ', maze[chosen_nghbr.x][chosen_nghbr.y])
				print('maze so far...') 
				print(maze)

			visited_maze[chosen_nghbr.x][chosen_nghbr.y] = 1
			stack.push_back(chosen_nghbr)
			
func connect_cell_with_nghbr(maze, cell, nghbr_cell):
	# Create the path
	var direction_to_open_cell_pov: Vector2 = nghbr_cell - cell  # 1,2 - 1,1 = 0,1
	var direction_to_open_nghbr_pov: Vector2 = cell - nghbr_cell # 1,1 - 1,2 = 0,-1

	#print('direction ', direction, ' decimal obtained: ', decimal_from_directions[direction])
	maze[cell.x][cell.y] -= decimal_from_directions[direction_to_open_cell_pov]
	maze[nghbr_cell.x][nghbr_cell.y] -= decimal_from_directions[direction_to_open_nghbr_pov]
	
func empty_maze(val: int):
	var maze: Array = []
	for i in MAZE_HEIGHT:
		maze.append([])
		for j in MAZE_WIDTH:
			maze[i].append(val)
	return maze

# j == x
# i == y
func place_borders(visited_maze):
	# techito
	for j in MAZE_WIDTH:
		visited_maze[-1][j] = 1
	# piso
	for j in MAZE_WIDTH:
		visited_maze[0][j] = 1
	# pared der
	for i in MAZE_HEIGHT:
		visited_maze[i][-1] = 1
	# pared izq
	for i in MAZE_HEIGHT:
		visited_maze[i][0] = 1
