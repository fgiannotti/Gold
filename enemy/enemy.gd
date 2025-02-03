class_name Enemy
extends CharacterBody2D

@export var stats: EnemyData
var run_sprite: Texture2D
var walk_sprite: Texture2D
var max_speed: float
var hp: float


@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	randomize()
	walk_sprite = stats.walk_sprite
	run_sprite = stats.run_sprite
	
	sprite.texture = stats.walk_sprite
	max_speed = stats.max_speed
	hp = stats.hp
	
	
