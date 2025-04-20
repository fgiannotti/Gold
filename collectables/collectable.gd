extends Node2D

# Generic collectable, use it if it fulfills your needs
# Or create your own .gd if you need to extend it (more variables)
class_name Collectable

@export var collectableAsItem: InventoryItem
@onready var texture = $Sprite2D
@onready var animations = $AnimationPlayer

var animation_name = "collect"
var player_in_area = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var collected = false
func collect() -> InventoryItem:
	print('[Collectable] collect called!!')
	if !player_in_area:
		print('[Collectable] collect called but player no in area, returning...')
		return
	if animations != null: 
		animations.play(animation_name)
		await animations.animation_finished
	if collected:
		return null
	collected = true

	queue_free()
	return collectableAsItem

func facing_left():
	$Sprite2D.frame = 6
	animation_name += "_left"

func facing_right():
	$Sprite2D.frame = 4
	animation_name += "_right"

func facing_up():
	$Sprite2D.frame = 2
	animation_name += "_up"

func facing_down():
	$Sprite2D.frame = 0
	animation_name += "_down"
	
func _on_collectable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		print('[Collectable] player in area')
		player_in_area = true


func _on_collectable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		print('[Collectable] player left area')
		player_in_area = false
