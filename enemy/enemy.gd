class_name Enemy
extends CharacterBody2D

@export var stats: EnemyData

var max_speed: float
var start_position
var end_position
var limit = 1

@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	randomize()
	max_speed = stats.max_speed
	sprite.texture = stats.sprite
	start_position = position
	end_position = start_position + Vector2(0,3*50)
