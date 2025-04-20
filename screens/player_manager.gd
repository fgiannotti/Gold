extends Node

const PLAYER_SPEED = 180
const STEPS_FOR_HUNGER = 50

const INITIAL_GOLD: int = 100
const INITIAL_FOOD: float = 100
const INITIAL_HEALTH: float = 100

signal hp_updated(new_hp: float)
signal food_updated(new_food: float)


var health: float = INITIAL_HEALTH
var food: float = INITIAL_FOOD
var gold: int = INITIAL_GOLD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_health(new_health: float):
	self.health = new_health
	hp_updated.emit(new_health) 

func set_food(new_food: float):
	print('[PlayerManager] setting food ', new_food)
	self.food = new_food
	food_updated.emit(new_food) 
	
func restart():
	PlayerManager.food = INITIAL_FOOD
	PlayerManager.gold = INITIAL_GOLD
	PlayerManager.health = INITIAL_HEALTH
