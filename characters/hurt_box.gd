class_name HurtBox extends Area2D

@onready var shape: CollisionShape2D = $CollisionShape2D

signal hit(damage_direction: Vector2, damage_amount: int)

func take_damage(damage_direction: Vector2, amount: int) -> void:
	hit.emit(damage_direction, amount)
