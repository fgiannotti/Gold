extends Node

var player: Player = null
var current_npc = null
var inventoryGUI: InventoryGUI = null

func start_interaction():
	if current_npc:
		current_npc.start_interaction()

func interaction_started():
	print('[InteractionManager] interaction started received')
	player.is_interacting = true  # Disable movement

func interaction_finished():
	print('[InteractionManager] interaction finished received')
	current_npc = null
	player.is_interacting = false  # Re-enable movement

func set_current_npc(npc: Node2D):
	current_npc = npc
	if npc is Muki:
		inventoryGUI.activate_sell_mode()

func unset_npc(npc):
	if current_npc == npc:
		current_npc = null
	if npc is Muki:
		inventoryGUI.deactivate_sell_mode()
func set_player(p):
	player = p
	
func set_inventory(i):
	inventoryGUI = i

func buy_item(shopItem: ShopItem):
	# TODO: Avoid negative money
	print('BUYING ITEMMM: ', shopItem.inventoryItem.name)
	player.gold -= shopItem.price
	inventoryGUI.inventory.insert(shopItem.inventoryItem)

func sell_item(inv_item: InventoryItem, amount: int):
	print('SELLING ITEMMM: ', inv_item.name)
	player.gold += inv_item.sell_price * amount
	inventoryGUI.inventory.delete(inv_item)
