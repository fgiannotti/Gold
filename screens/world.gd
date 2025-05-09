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
	reroll_muki_position_until_valid()

# this avoids having muki and collectables on the same tile
func reroll_muki_position_until_valid():
	var choosing_pos = true
	while choosing_pos:
		var valid_pos = walls.get_random_room_pos_to_global()
		var collectable: Node2D = $TileMap/collectables.collectable_at_world_pos(valid_pos)
		print('[World] got pos and collectable ', valid_pos, collectable)
		if !collectable || collectable.is_in_group("minerals"):
			if walls.global_pos_inside_room(valid_pos):
				print('[World] Setting muki in ', valid_pos)
				$Muki.global_position = valid_pos
				choosing_pos = false
'''
# To debug stuff

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
