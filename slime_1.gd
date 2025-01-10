extends CharacterBody2D


const SPEED = 15
var start_position
var end_position
var limit = 1

@onready var animations = $SlimeSprite

func _ready() -> void:
	start_position = position
	end_position = start_position + Vector2(0,3*50)

func change_direction():
	var temp_end = end_position
	end_position = start_position
	start_position = temp_end
	

func update_velocity():
	var move_direction = (end_position - position)
	if move_direction.length() < limit:
		change_direction()
	velocity = move_direction.normalized() * SPEED

func update_animation():
	var animation_string = "walkUp"
	if velocity.y > 0:
		animation_string = "walkDown"
	if velocity.x > 0:
		animation_string = "walkRight" 
	if velocity.x < 0:
		animation_string = "walkLeft"
	
	animations.play(animation_string)

func _physics_process(delta: float) -> void:
	update_velocity()
	move_and_slide()
	update_animation()
