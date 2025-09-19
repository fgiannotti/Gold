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
	CollectableAutoloader.walls_tilemap = $TileMap/walls
	CollectableAutoloader.collectables_tilemap = $TileMap/collectables
	BreakablesAutoloader.walls_tilemap = $TileMap/walls
	BreakablesAutoloader.collectables_tilemap = $TileMap/collectables
	
	walls.maze_rebuilt.connect($Player/Camera2D.update_limits)
	
	walls.restart_maze()
	
	$CanvasLayer/InventoryGUI.show()
	$SceneTransitioner.process_mode = Node.PROCESS_MODE_ALWAYS
	$FogOfWar.process_mode = Node.PROCESS_MODE_ALWAYS
	PlayerManager.hp_updated.connect(_on_hp_updated)
	_on_hp_updated(PlayerManager.health)
	PlayerManager.food_updated.connect(_on_food_updated)
	_on_food_updated(PlayerManager.food)
	
	# PlacementManager is already initialized by walls.restart_maze()
	# Just place interactables using the global placement manager
	PlacementManager.place_interactable_safely($Muki, walls)
	await get_tree().process_frame
	print("[WORLD] Total children in collectables after spawn: ", $TileMap/collectables.get_child_count())
	
	place_on_room_ceiling($Forge)


# Places a node on a tile with ROOM_CEILING value
func place_on_room_ceiling(node: Node2D):
	print("\n\n[FORGE_DEBUG] ========== STARTING FORGE PLACEMENT ==========")
	
	if walls.rooms.size() == 0:
		print('[FORGE_DEBUG] No rooms found, using fallback method')
		PlacementManager.place_interactable_safely(node, walls)
		return
	
	# Get all ceiling positions from all rooms
	var ceiling_positions = get_all_ceiling_positions()
	
	if ceiling_positions.size() == 0:
		print("[FORGE_DEBUG] No ceiling positions found, using fallback method")
		PlacementManager.place_interactable_safely(node, walls)
		return
	
	# Find an unoccupied ceiling position
	var available_positions = []
	for ceiling_pos in ceiling_positions:
		if not PlacementManager.is_position_occupied(ceiling_pos.world):
			available_positions.append(ceiling_pos)
	
	if available_positions.size() > 0:
		var chosen_pos = available_positions[randi() % available_positions.size()]
		
		print("[FORGE_DEBUG] Setting Forge at world position: " + str(chosen_pos.world) + 
			  " (tilemap: " + str(chosen_pos.tilemap) + ")")
		
		node.global_position = chosen_pos.world
		PlacementManager.mark_position_occupied(chosen_pos.world)
	else:
		print("[FORGE_DEBUG] No available ceiling positions, using fallback method")
		PlacementManager.place_interactable_safely(node, walls)
	
	print("[FORGE_DEBUG] ========== FORGE PLACEMENT COMPLETE ==========\n\n")

# Get all ceiling positions from all rooms
func get_all_ceiling_positions() -> Array:
	var ceiling_positions = []
	
	for room in walls.rooms:
		print("[FORGE_DEBUG] Checking room at position: " + str(room.position) + 
			  ", top_gate: " + str(room.top_gate) + 
			  ", width finish: " + str(room.width_line_finish))
		
		# Check each position along the top of the room (ceiling)
		for x in range(room.position.x + 1, room.width_line_finish):
			var tilemap_pos = Vector2(x, room.position.y)
			
			# Skip gate positions (gates should not have interactables)
			if room.top_gate != Vector2(-1, -1) and x == room.top_gate.y:
				continue
			
			# Verify this is actually a ceiling tile by checking the tilemap data
			# Since we know ceiling tiles are placed at room.position.y during room generation,
			# we can trust that positions along the top edge are ceiling tiles
			var world_pos = walls.map_to_local(tilemap_pos)
			ceiling_positions.append({"tilemap": tilemap_pos, "world": world_pos})
			print("[FORGE_DEBUG]   • Valid ceiling position: tilemap=" + str(tilemap_pos) + ", world=" + str(world_pos))
	
	return ceiling_positions

# Legacy function - now uses the new safe placement system
func reroll_position_until_in_open_room(node: Node2D):
	print('[reroll_position_until_in_open_room] Using PlacementManager for: ' + node.name)
	PlacementManager.place_interactable_safely(node, walls)

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
	get_tree().paused = false
	# Store inventory count before transitioning to avoid freed object access
	PlayerManager.store_final_inventory_count()
	$SceneTransitioner.trigger_lose()

func _on_food_bar_player_starved() -> void:
	get_tree().paused = false
	# Store inventory count before transitioning to avoid freed object access
	PlayerManager.store_final_inventory_count()
	$SceneTransitioner.trigger_lose()

func _on_ladder_area_body_entered(body: Node2D) -> void:
	floor += 1
	get_tree().paused = true  # Pauses everything
	if floor == 3:
		# Store inventory count before transitioning to avoid freed object access
		get_tree().paused = false
		PlayerManager.store_final_inventory_count()
		$SceneTransitioner.trigger_win()
		return

	await $SceneTransitioner.trigger_veil_screen()
	$FogOfWar.reset()
	$CanvasLayer/Floor.update_floor(floor)
	$TileMap/walls.restart_maze()
	await $SceneTransitioner.trigger_unveil_screen()
	get_tree().paused = false 
