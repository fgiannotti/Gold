class_name HealingEffect extends InteractableEffect

@export var heal_amount: float = 20.0

func _init():
	effect_name = "Healing Effect"
	effect_description = "Restores player health"

func apply_effect() -> void:
	print("[HealingEffect] Healing player for: ", heal_amount)
	
	# Add health to the player
	var current_health = PlayerManager.health
	var new_health = min(PlayerManager.INITIAL_HEALTH, current_health + heal_amount)
	PlayerManager.set_health(new_health)
	
	print("[HealingEffect] Player healed from ", current_health, " to ", new_health) 