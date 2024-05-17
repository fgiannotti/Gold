extends TileMap

const MAZE_WIDTH =  5
const MAZE_HEIGHT = 5  # counting from 0

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

const decimal_max: int = 15 # 0 to 15 are the possibles decimal values of the tile set

# Called when the node enters the scene tree for the first time.
func _ready():

	for i in MAZE_HEIGHT:
		for j in MAZE_WIDTH:
			print('set_cell')
			set_cell(0, Vector2i(i,j),0,Vector2i(0,0),0)
	generate_maze()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var stack = []
func generate_maze():
	var maze: Array = empty_maze(1)
	var visited_maze: Array = empty_maze(0)
	var starting_cell = Vector2(1,1)
	print(maze)
	visited_maze[starting_cell.x][starting_cell.y] = 1
	stack.append(starting_cell)
	print('Executing maze build')
	place_borders(visited_maze)
	build_with_backtracking(maze, visited_maze)
	print(maze)

func build_with_backtracking(maze, visited_maze):
	var cell: Vector2
	while stack.size() > 0:
		print('-----------')
		cell = stack.pop_back()
		print('Iterating with cell: ', cell, ' and stack: ', stack)
		# Build neighbors
		#if int(cell.x) % 2 == 0 && int(cell.y) % 2 == 0:
			#print('placing cell as visited', cell)
			#visited_maze[cell.x][cell.y] = 1
			#maze[cell.x][cell.y] = 1
			#continue

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
			# Create the path
			var direction_to_open_cell_pov: Vector2 = chosen_nghbr - cell  # 1,2 - 1,1 = 0,1
			var direction_to_open_nghbr_pov: Vector2 = cell - chosen_nghbr # 1,1 - 1,2 = 0,-1

			#print('direction ', direction, ' decimal obtained: ', decimal_from_directions[direction])
			if maze[cell.x][cell.y] == 1:
				maze[cell.x][cell.y] = decimal_max - decimal_from_directions[direction_to_open_cell_pov]
			else:
				maze[cell.x][cell.y] -= decimal_from_directions[direction_to_open_cell_pov]

			if maze[chosen_nghbr.x][chosen_nghbr.y] == 1:
				maze[chosen_nghbr.x][chosen_nghbr.y] = decimal_max - decimal_from_directions[direction_to_open_nghbr_pov]
			else:
				maze[chosen_nghbr.x][chosen_nghbr.y] -= decimal_from_directions[direction_to_open_nghbr_pov]

			print('From cell:', cell, ' value: ',maze[cell.x][cell.y] ,' chosen neighbor: ', chosen_nghbr, '  neighbors: ', neighbors,' with value: ', maze[chosen_nghbr.x][chosen_nghbr.y])
			print('maze so far...')
			print(maze)

			visited_maze[chosen_nghbr.x][chosen_nghbr.y] = 1
			stack.push_back(chosen_nghbr)

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
