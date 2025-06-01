class_name BreakableInteractable extends Collectable

# Configuration resource that defines all properties
@export var config: BreakableConfig
@export var is_broken: bool = false

# Hurt box for detecting attacks
@onready var hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	super._ready()
	
	# Apply configuration if available
	if config:
		apply_config()
	
	# Connect the hurt box signal to our breaking function
	if hurt_box:
		hurt_box.hit.connect(_on_hit)
	# Disable the normal collectable area since we use attacks instead
	if has_node("CollectableArea"):
		$CollectableArea.set_deferred("monitoring", false)

func apply_config():
	if not config:
		return
		
	# Apply visual properties
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		if config.texture:
			sprite.texture = config.texture
		sprite.modulate = config.modulate_color
		sprite.frame = config.sprite_frame
	
	# Apply behavior properties
	collectableAsItem = config.collectableAsItem
	
	# Create break animation if it doesn't exist
	if animations and not animations.has_animation(config.break_animation_name):
		create_break_animation()

func create_break_animation():
	if not animations or not config:
		return
		
	# Create a simple break animation
	var animation = Animation.new()
	animation.length = config.break_animation_duration
	
	# Add modulate track (fade out only)
	var modulate_track = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(modulate_track, NodePath("Sprite2D:modulate"))
	
	# Simple fade out - no scaling
	# Start with normal color, brief flash, then fade to transparent
	animation.track_insert_key(modulate_track, 0.0, config.modulate_color)
	animation.track_insert_key(modulate_track, config.break_animation_duration * 0.2, Color.WHITE)
	animation.track_insert_key(modulate_track, config.break_animation_duration, Color.TRANSPARENT)
	
	# Add animation to library
	var library = animations.get_animation_library("")
	if not library:
		library = AnimationLibrary.new()
		animations.add_animation_library("", library)
	
	library.add_animation(config.break_animation_name, animation)

func _on_hit(damage_direction: Vector2, damage_amount: int) -> void:
	if is_broken:
		return
	
	print("[BreakableInteractable] Hit with damage: ", damage_amount)
	break_interactable()

func break_interactable():
	if is_broken:
		return
		
	is_broken = true
	print("[BreakableInteractable] Breaking!")
	
	# Track the breakable destruction
	GameStats.breakable_destroyed()
	
	# Play break animation if it exists
	var anim_name = config.break_animation_name if config else "break"
	if animations and animations.has_animation(anim_name):
		animations.play(anim_name)
		await animations.animation_finished
	
	# Apply effects (buffs, debuffs, etc.)
	apply_effects()
	
	# Handle item drop
	handle_item_drop()
	
	# Clean up
	queue_free()

func apply_effects():
	if not config:
		return
		
	for effect in config.effects:
		if effect:
			effect.apply_effect()

func handle_item_drop():
	var item = config.collectableAsItem if config else collectableAsItem
	var chance = config.drop_chance if config else 1.0
	
	if item and randf() <= chance:
		# Track item collection
		GameStats.item_collected()
		
		# Use InteractionManager to access the inventory (same pattern as other systems)
		if InteractionManager.inventoryGUI:
			InteractionManager.inventoryGUI.add_item(item)
			print("[BreakableInteractable] Dropped item: ", item.name)
		else:
			print("[BreakableInteractable] Could not find inventory through InteractionManager")

# Override the collect method to prevent normal collection
func collect() -> InventoryItem:
	print("[BreakableInteractable] Cannot be collected normally - must be broken with attacks!")
	return null 
