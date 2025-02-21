class_name Enemy
extends CharacterBody2D

@export var enemy_data: EnemyData
var max_speed: float
var hp: float


@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	randomize()
	sprite.texture = enemy_data.walk_sprite
	max_speed = enemy_data.max_speed
	hp = enemy_data.hp

func _physics_process(delta: float) -> void:
	pass
