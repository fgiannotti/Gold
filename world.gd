extends Node2D

@onready var food_bar = $CanvasLayer/FoodBar

# Called when the node enters the scene tree for the first time.
func _ready():
	food_bar.init_food(100)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_inventory_closed() -> void:
	get_tree().paused = false


func _on_inventory_opened() -> void:
	get_tree().paused = true

func _on_travel_area_body_entered(_body: Node2D) -> void:
	$TileMap/walls.restart_maze()
