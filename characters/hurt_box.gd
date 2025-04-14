class_name HurtBox extends Area2D

@onready var shape: CollisionShape2D = $CollisionShape2D

signal hit(damage_amount: int)

func take_damage(amount: int) -> void:
	hit.emit(amount)
