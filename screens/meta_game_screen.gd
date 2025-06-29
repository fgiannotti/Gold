extends Control

@onready var gold_label = $VBoxContainer/ResourcesContainer/GoldContainer/GoldLabel
@onready var minerals_label = $VBoxContainer/ResourcesContainer/MineralsContainer/MineralsLabel
@onready var play_button = $VBoxContainer/ButtonsContainer/PlayButton
@onready var upgrades_container = $VBoxContainer/UpgradesContainer/ScrollContainer/UpgradesGrid

func _ready():
	PlayerManager.meta_stats_changed.connect(update_display)
	PlayerManager.meta_stats_changed.connect(setup_upgrades)
	update_display()
	setup_upgrades()
	play_button.pressed.connect(_on_play_button_pressed)

func update_display():
	gold_label.text = str(PlayerManager.meta_gold) + " G"
	minerals_label.text = str(PlayerManager.meta_minerals) + " Minerals"

func setup_upgrades():
	# Clear existing children
	for child in upgrades_container.get_children():
		child.queue_free()
	
	# Create upgrade items
	for upgrade in PlayerManager.upgrades:
		create_upgrade_item(upgrade)

func create_upgrade_item(upgrade_data: Dictionary):
	var upgrade_item = preload("res://screens/upgrade_item.tscn").instantiate()
	upgrades_container.add_child(upgrade_item)
	upgrade_item.setup_upgrade(upgrade_data, self)

func can_afford_upgrade(upgrade_data: Dictionary) -> bool:
	return PlayerManager.can_afford_upgrade(upgrade_data)

func purchase_upgrade(upgrade_data: Dictionary):
	PlayerManager.purchase_upgrade(upgrade_data)
	print("[MetaGameScreen] Purchased upgrade: ", upgrade_data.name)

func _on_play_button_pressed():
	# Add transition effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	get_tree().change_scene_to_file("res://screens/world.tscn") 
