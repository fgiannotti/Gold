extends Area2D

var can_attack = true
@onready var cooldown_timer = $AttackCooldown
@onready var enemy : Enemy = get_owner()
@export var knockbackPower: int = 2000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_body_entered(body: Node2D) -> void:
	if body is Player and can_attack:
		body.recive_damage(1)
		can_attack = false
		cooldown_timer.start()
		knockback()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func knockback():
	var knockbackDireciton = -enemy.velocity.normalized() * knockbackPower
	enemy.velocity = knockbackDireciton
	enemy.move_and_slide()
