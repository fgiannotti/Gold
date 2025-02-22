extends Node

var player: Player = null
var current_npc = null
var inventory: Inventory = null

func start_interaction():
	if current_npc:
		current_npc.start_interaction()

func _on_npc_interaction_started():
	player.is_interacting = true  # Disable movement

func _on_npc_interaction_finished():
	player.is_interacting = false  # Re-enable movement

func set_current_npc(npc):
	current_npc = npc

func unset_npc(npc):
	if current_npc == npc:
		current_npc = null

func set_player(p):
	player = p
func set_inventory(i):
	inventory = i

func buy_item(shopItem: ShopItem):
	# TODO: Avoid negative money
	print('BUYING ITEMMM: ', shopItem.inventoryItem.name)
	player.gold -= shopItem.price
	inventory.insert(shopItem.inventoryItem)
	
