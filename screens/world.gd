extends Node2D

@onready var food_bar = $CanvasLayer/FoodBar
@onready var health_bar = $CanvasLayer/HealthBar
'''
@onready var name_label = $NinePatchRect/NameLabel
@onready var text_label = $NinePatchRect/TextLabel
@onready var ninepatch_rect = $NinePatchRect
'''

var floor = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	food_bar.init_food(PlayerManager.food)
	health_bar.init_health(PlayerManager.health)
	DialogueManager.set_dialogue_ui($CanvasLayer/Dialogue)
	InteractionManager.set_player($Player)
	InteractionManager.set_inventory($CanvasLayer/InventoryGUI)
	InteractionManager.set_health_bar($CanvasLayer/HealthBar)
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
