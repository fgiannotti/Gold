extends Node2D

@onready var food_bar = $CanvasLayer/TopRight/VBoxContainer/MarginContainer/FoodBar
@onready var health_bar = $CanvasLayer/TopRight/VBoxContainer/MarginContainer2/HealthBar
'''
@onready var name_label = $NinePatchRect/NameLabel
@onready var text_label = $NinePatchRect/TextLabel
@onready var ninepatch_rect = $NinePatchRect
'''
@onready var walls: Walls = $TileMap/walls

var artifact : PackedScene = preload("res://artifacts/artifact.tscn")

var floor = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	food_bar.init_food(PlayerManager.food)
	health_bar.init_health(PlayerManager.health)
	DialogueManager.set_dialogue_ui($CanvasLayer/Dialogue)
	InteractionManager.set_player($Player)
	InteractionManager.set_inventory($CanvasLayer/InventoryGUI)
	InteractionManager.set_health_bar($CanvasLayer/TopRight/HealthBar)
	MineralAutoloader.walls_tilemap = $TileMap/walls
	MineralAutoloader.collectables_tilemap = $TileMap/collectables
	MineralAutoloader.spawn_all_minerals()
	CollectableAutoloader.walls_tilemap = $TileMap/walls
	CollectableAutoloader.collectables_tilemap = $TileMap/collectables
	CollectableAutoloader.spawn_all_collectables()
	$CanvasLayer/InventoryGUI.show()
	$SceneTransitioner.process_mode = Node.PROCESS_MODE_ALWAYS
	PlayerManager.hp_updated.connect(_on_hp_updated)
	_on_hp_updated(PlayerManager.health)
	PlayerManager.food_updated.connect(_on_food_updated)
	_on_food_updated(PlayerManager.food)
	reroll_position_until_in_open_room($Muki)
	place_on_room_ceiling($Forge)

# Places a node on a tile with ROOM_CEILING value
func place_on_room_ceiling(node: Node2D):
	if walls.rooms.size() == 0:
		print('[World] No rooms found, using fallback method')
		reroll_position_until_in_open_room(node)
		return
	
	# Get a random room
	var random_room = walls.rooms[randi() % walls.rooms.size()]
	
	# Get ceiling positions for this room
	var ceiling_positions = []
	for x in range(random_room.position.x + 1, random_room.width_line_finish):
		ceiling_positions.append(Vector2i(x, random_room.position.y))
	
	if ceiling_positions.size() > 0:
		# Pick a random ceiling position
		var random_pos = ceiling_positions[randi() % ceiling_positions.size()]
		# Convert to global position
		var global_pos = walls.map_to_local(random_pos)
		# Check if there's a collectable there
		var collectable = $TileMap/collectables.collectable_at_tile(random_pos)
		
		# If no collectable, place the forge
		if !collectable:
			print('[World] Setting Forge on ROOM_CEILING at position ', global_pos)
			node.global_position = global_pos
		else:
			# If there's a collectable, try another room
			print('[World] Collectable found at ceiling position, trying another room')
			place_on_room_ceiling(node)
	else:
		print('[World] No ceiling positions found in selected room, using fallback method')
		reroll_position_until_in_open_room(node)

# this avoids having the node and collectables on the same tile
func reroll_position_until_in_open_room(node: Node2D):
	var choosing_pos = true
	var max_attempts = 20
	var attempt_count = 0
	
	while choosing_pos and attempt_count < max_attempts:
		attempt_count += 1
		var valid_pos = walls.get_random_room_pos_to_global()
		var collectable: Node2D = $TileMap/collectables.collectable_at_world_pos(valid_pos)
		print('[World] attempt %d: pos=%s, collectable=%s' % [attempt_count, valid_pos, collectable])
		
		if (!collectable || collectable.is_in_group("minerals")) and walls.global_pos_inside_room(valid_pos):
			print('[World] Setting node in ', valid_pos)
			node.global_position = valid_pos
			choosing_pos = false
	
	# If we couldn't find a position after maximum attempts, use a fallback
	if choosing_pos:
		print('[World] Could not find valid position after %d attempts, using fallback' % max_attempts)
		# Fallback: just find a valid room position without checking for collectables
		var positions = walls.positions_open_room
		if positions.size() > 0:
			var fallback_pos = walls.to_global(positions[randi() % positions.size()])
			print('[World] Fallback position: ', fallback_pos)
			node.global_position = fallback_pos

# To debug stuff
'''

var creating = false
func _input(event):
	creating = true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print('creating stuff')
		var art: Artifact = artifact.instantiate()
		art.create(load("res://artifacts/sword_artifact.tres"))
		$CanvasLayer/Artifacts/GridContainer.add_child(art)
	get_tree().create_timer(2).timeout
	creating = false
'''


# Update UI
func _on_hp_updated(new_hp: float):
	health_bar.update_health(new_hp)

# Update UI
func _on_food_updated(new_food: int):
	food_bar.update_food(new_food)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_inventory_closed() -> void:
	get_tree().paused = false


func _on_inventory_opened() -> void:
	# get_tree().paused = true
	pass

func _on_health_bar_player_died() -> void:
	$SceneTransitioner.trigger_lose()

func _on_food_bar_player_starved() -> void:
	$SceneTransitioner.trigger_lose()

func _on_ladder_area_body_entered(body: Node2D) -> void:
	floor += 1
	get_tree().paused = true  # Pauses everything
	if floor == 3:
		$SceneTransitioner.trigger_win()
		return

	await $SceneTransitioner.trigger_veil_screen()
	$CanvasLayer/Floor.update_floor(floor)
	$TileMap/walls.restart_maze()
	await $SceneTransitioner.trigger_unveil_screen()
	get_tree().paused = false 
