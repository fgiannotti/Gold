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
	BreakablesAutoloader.walls_tilemap = $TileMap/walls
	BreakablesAutoloader.collectables_tilemap = $TileMap/collectables
	BreakablesAutoloader.spawn_all_breakables()
	$CanvasLayer/InventoryGUI.show()
	$SceneTransitioner.process_mode = Node.PROCESS_MODE_ALWAYS
	$FogOfWar.process_mode = Node.PROCESS_MODE_ALWAYS
	PlayerManager.hp_updated.connect(_on_hp_updated)
	_on_hp_updated(PlayerManager.health)
	PlayerManager.food_updated.connect(_on_food_updated)
	_on_food_updated(PlayerManager.food)
	reroll_position_until_in_open_room($Muki)
	await get_tree().process_frame
	print("[WORLD] Total children in collectables after spawn: ", $TileMap/collectables.get_child_count())
	
	place_on_room_ceiling($Forge)

# Places a node on a tile with ROOM_CEILING value
func place_on_room_ceiling(node: Node2D):
	print("\n\n[FORGE_DEBUG] ========== STARTING FORGE PLACEMENT ==========")
	
	if walls.rooms.size() == 0:
		print('[FORGE_DEBUG] No rooms found, using fallback method')
		reroll_position_until_in_open_room(node)
		return
	
	# STEP 1: Get all mineral positions in WORLD coordinates
	var mineral_world_positions = []
	
	print("[FORGE_DEBUG] Scanning all children in collectables:")
	for child in $TileMap/collectables.get_children():
		if child is Node2D:
			# print("[FORGE_DEBUG]   • Found: " + child.name + " at position: " + str(child.position) +  " [Groups: " + str(child.get_groups()) + "]")
			mineral_world_positions.append(child.position)
	
	# STEP 2: Get all ceiling positions
	var random_room = walls.rooms[0] # Use first room consistently for debugging
	
	print("[FORGE_DEBUG] Using room at position: " + str(random_room.position) + 
		  ", top_gate: " + str(random_room.top_gate) + 
		  ", width finish: " + str(random_room.width_line_finish))
	
	var ceiling_world_positions = []
	for x in range(random_room.position.x + 1, random_room.width_line_finish):
		if x != random_room.top_gate.y: # gates are inverted
			var tilemap_pos = Vector2(x, random_room.position.y)
			var world_pos = walls.map_to_local(tilemap_pos)
			ceiling_world_positions.append({"tilemap": tilemap_pos, "world": world_pos})
			print("[FORGE_DEBUG]   • Ceiling position: tilemap=" + str(tilemap_pos) + ", world=" + str(world_pos))
	
	# STEP 3: Find a ceiling position that is FAR from any mineral
	print("[FORGE_DEBUG] Checking for available ceiling positions...")
	var available_positions = []
	var SAFE_DISTANCE = 32 # Use a VERY large distance to be sure
	
	for ceiling_pos in ceiling_world_positions:
		var is_occupied = false
		for mineral_pos in mineral_world_positions:
			var distance = ceiling_pos.world.distance_to(mineral_pos)
			#print("[FORGE_DEBUG]   • Distance from " + str(ceiling_pos.world) +  " to mineral at " + str(mineral_pos) + ": " + str(distance))
			
			if distance < SAFE_DISTANCE:
				print("[FORGE_DEBUG]     - TOO CLOSE! Position is occupied")
				is_occupied = true
				break
		
		if not is_occupied:
			# print("[FORGE_DEBUG]     + AVAILABLE! Adding to available positions")
			available_positions.append(ceiling_pos)
	
	# STEP 4: Choose a position and place the forge
	if available_positions.size() > 0:
		var chosen_pos = available_positions[randi() % available_positions.size()]
		
		print("[FORGE_DEBUG] Setting Forge at world position: " + str(chosen_pos.world) + 
			  " (tilemap: " + str(chosen_pos.tilemap) + ")")
		
		node.global_position = chosen_pos.world
	else:
		print("[FORGE_DEBUG] No available ceiling positions, using fallback method")
		reroll_position_until_in_open_room(node)
	
	print("[FORGE_DEBUG] ========== FORGE PLACEMENT COMPLETE ==========\n\n")

# this avoids having the node and collectables on the same tile
func reroll_position_until_in_open_room(node: Node2D):
	var choosing_pos = true
	var max_attempts = 20
	var attempt_count = 0
	
	while choosing_pos and attempt_count < max_attempts:
		attempt_count += 1
		var valid_pos = walls.get_random_room_pos_to_global()
		var collectable: Node2D = $TileMap/collectables.collectable_at_world_pos(valid_pos)
		print('[reroll_position_until_in_open_room] attempt %d: pos=%s, collectable=%s' % [attempt_count, valid_pos, collectable])
		
		if (!collectable || collectable.is_in_group("minerals")) and walls.global_pos_inside_room(valid_pos):
			print('[reroll_position_until_in_open_room] Setting node in ', valid_pos)
			node.global_position = valid_pos
			choosing_pos = false
	
	# If we couldn't find a position after maximum attempts, use a fallback
	if choosing_pos:
		print('[reroll_position_until_in_open_room] Could not find valid position after %d attempts, using fallback' % max_attempts)
		# Fallback: just find a valid room position without checking for collectables
		var positions = walls.positions_open_room
		if positions.size() > 0:
			var fallback_pos = walls.to_global(positions[randi() % positions.size()])
			print('[reroll_position_until_in_open_room] Fallback position: ', fallback_pos)
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
