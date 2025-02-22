extends Node2D

signal interaction_started
signal interaction_finished

@export var dialogue: Array[Dictionary] = [
	{"name": "Muki", "text": " Welcome stinky human."},
	{"name": "Muki", "text": " Many miners come and trade with me to survive longer... but none return HAHA!"},
	{"name": "Muki", "text": " Anyways, here is what I got."}
]

const coin_path = "[img=12x12]res://assets/inventory/coin-basic.png[/img]"

func start_interaction():
	interaction_started.emit()
	print('starting dialogue')
	await DialogueManager.start_dialogue(dialogue)
	print('finished dialogue')

	interaction_finished.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShopItem.set_shop_item(load( "res://characters/muki/slime_tears_shop_item.tres"))
	$ShopItem2.set_shop_item(load("res://characters/muki/fire_slime_tears_shop_item.tres"))
	$ShopUI.hide()
	var shop_items = get_tree().get_nodes_in_group("shop_items")

	for item in shop_items:
		if not item.item_hovered.is_connected(_on_shop_item_hovered):
			item.connect("item_hovered", _on_shop_item_hovered)
			print("✅ Connected item_hovered signal from:", item.name)
		else:
			print("⚠️ Already connected:", item.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_talkable_area_body_entered(body: Node2D) -> void:
	print('talkable area entered')
	if body is Player:  # Ensure it's the player
		InteractionManager.set_current_npc(self)
		print('setting current npc')

func _on_talkable_area_body_exited(body: Node2D) -> void:
	print('talkable area exited')
	$ShopUI.hide()
	if body is Player:  # Ensure it's the player
		InteractionManager.unset_npc(self)
		print('un-setting current npc')

func _on_shop_item_hovered(shop_item: ShopItem) -> void:
	selected_shop_item = shop_item
	print("[Muki] Got shop item name: ", shop_item.inventoryItem.name)
	print("[Muki] Got shop item desc: ", shop_item.description)

	$ShopUI/ItemDetails/Title.text = shop_item.inventoryItem.name
	$ShopUI/ItemDetails/Description.text = shop_item.description
	$ShopUI/ItemDetails/Price.text = coin_path + str(shop_item.price) +"G" 
	$ShopUI.show()

func _on_interactable_area_body_exited(body: Node2D) -> void:
	selected_shop_item = null
	print('[Muki] area exited')
	$ShopUI.hide()


func _input(event: InputEvent) -> void:
	if $ShopUI.is_visible() and event.is_action_pressed("use"):
		print('[Muki] buying item!!! ', selected_shop_item.inventoryItem.name)
		InteractionManager.buy_item(selected_shop_item)
		delete_related_item(selected_shop_item)
		$ShopUI.hide()
		selected_shop_item = null
		
func delete_related_item(shop_item: ShopItem):
	print("[Muki] 🗑 Deleting shop item:", shop_item.inventoryItem.name)

	var shop_items = get_tree().get_nodes_in_group("shop_items")  # Get all shop items

	for item in shop_items:
		if item.shop_item == shop_item:  # Compare the stored ShopItem resource
			print("[Muki] ✅ Found and deleting:", item.name)
			item.queue_free()  # Remove from the scene
			return  # Stop after deleting the first match

	print("[Muki] ⚠️ Shop item not found in scene.")

var selected_shop_item: ShopItem = null
