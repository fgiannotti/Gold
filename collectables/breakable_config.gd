class_name BreakableConfig extends Resource

# Visual properties
@export var texture: Texture2D
@export var modulate_color: Color = Color.WHITE
@export var sprite_frame: int = 0

# Behavior properties
@export var drop_chance: float = 1.0
@export var collectableAsItem: InventoryItem
@export var effects: Array[InteractableEffect] = []

# Animation properties
@export var break_animation_name: String = "break"
@export var break_animation_duration: float = 0.5

# Description for editor
@export var config_name: String = "Basic Breakable"
@export var config_description: String = "A basic breakable object" 