class_name Raycasts360 extends Node2D

signal player_on_sight

var rays: Array[RayCast2D]
var is_player_on_sight: bool = false

#The idea is to disable the slime’s areas when returning from chasing.
#During the returning phase (not wandering), raycasts will spawn, and if they detect the player, they will reactivate the areas.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Gather all Raycast2D Nodes
	for c in get_children():
		if c is RayCast2D:
			rays.append( c )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_collision_player()
	if is_player_on_sight:
		emit_signal("player_on_sight")

func check_collision_player():
	for ray in rays:
		if ray.is_colliding():
			if ray.get_collider() == Player:
				is_player_on_sight = true
