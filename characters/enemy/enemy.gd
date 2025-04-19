class_name Enemy
extends CharacterBody2D

@export var enemy_data: EnemyData
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
var max_speed: float
var hp: float


func _ready() -> void:
	randomize()
	sprite.texture = enemy_data.walk_sprite
	max_speed = enemy_data.max_speed
	hp = enemy_data.hp

func _physics_process(delta: float) -> void:
	update_animation()
	
func update_animation():
	
	var velocity = self.velocity
	var direction = Vector2.ZERO
	
	if velocity.length() > 0:
		direction = velocity.normalized()
	
	if direction.x > 0 and abs(direction.x) > abs(direction.y):
		animation_player.play("walkRight")
	elif direction.x < 0 and abs(direction.x) > abs(direction.y):
		animation_player.play("walkLeft")
	elif self.velocity.y > 0:
		animation_player.play("walkDown")
	elif self.velocity.y < 0:
		animation_player.play("walkUp")

func _on_aggro_range_body_entered(body: Node2D) -> void:
	sprite.texture = self.enemy_data.run_sprite
	$Aggro/AggroRange/ExclamationMark.show()
	$Aggro/AggroRange/AggroMarkTimer.start()

func _on_de_aggro_range_body_exited(body: Node2D) -> void:
	sprite.texture = self.enemy_data.walk_sprite
	$Aggro/AggroRange/ExclamationMark.hide()

func _on_hurt_box_hit(damage_direction:Vector2, damage_amount: int) -> void:
	print("[Enemy] took damage ", damage_amount, self.hp)
	self.hp -= damage_amount
	if self.hp <= 0:
		print("[Enemy] trigger death")
		trigger_death()
		return
	$Effects.play("hurt")
	var player_atk_knockback_power = 4000 # for now hardcoded here
	$Cactus.knockback(damage_direction, player_atk_knockback_power)
	

func trigger_death():
	$Navigation.stop()
	$AnimationPlayer.play("dead")
	await $AnimationPlayer.animation_finished
	self.queue_free()

func _on_aggro_mark_timer_timeout() -> void:
	$Aggro/AggroRange/ExclamationMark.hide()
