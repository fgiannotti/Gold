class_name InteractableEffect extends Resource

# Base class for effects that can be applied when breaking interactables
# Extend this class to create specific effects like healing, damage, buffs, etc.

@export var effect_name: String = "Base Effect"
@export var effect_description: String = "Does something when triggered"

# Override this method in derived classes to implement the effect
func apply_effect() -> void:
	print("[InteractableEffect] Applying base effect: ", effect_name)
	# Base implementation does nothing - override in subclasses 
