class_name DamageEffect extends InteractableEffect

@export var damage_amount: float = 10.0

func _init():
	effect_name = "Damage Effect"
	effect_description = "Deals damage to player"

func apply_effect() -> void:
	print("[DamageEffect] Dealing damage to player: ", damage_amount)
	
	# Deal damage through the interaction manager
	InteractionManager.receive_damage(damage_amount)
	
	print("[DamageEffect] Player took ", damage_amount, " damage") 