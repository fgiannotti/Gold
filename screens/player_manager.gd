extends Node

const PLAYER_SPEED = 500
const STEPS_FOR_HUNGER = 50

const INITIAL_GOLD: int = 100
const INITIAL_FOOD: float = 100
const INITIAL_HEALTH: float = 100

signal hp_updated(new_hp: float)
signal food_updated(new_food: float)

var health: float = INITIAL_HEALTH
var food: float = INITIAL_FOOD
var gold: int = INITIAL_GOLD

# Store inventory data safely for end screens
var final_inventory_count: int = 0

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

func store_final_inventory_count():
	"""Store the current inventory count safely before scene transitions"""
	final_inventory_count = 0
	
	# Safely count inventory items
	if InteractionManager and is_instance_valid(InteractionManager.inventoryGUI):
		if InteractionManager.inventoryGUI.inventory and is_instance_valid(InteractionManager.inventoryGUI.inventory):
			for slot in InteractionManager.inventoryGUI.inventory.itemSlots:
				if slot and slot.item != null and slot.amount > 0:
					final_inventory_count += slot.amount
	
	print("[PlayerManager] Stored final inventory count: ", final_inventory_count)

func get_final_inventory_count() -> int:
	"""Get the safely stored inventory count for end screens"""
	return final_inventory_count
	
func restart():
	PlayerManager.food = INITIAL_FOOD
	PlayerManager.gold = INITIAL_GOLD
	PlayerManager.health = INITIAL_HEALTH
	final_inventory_count = 0
