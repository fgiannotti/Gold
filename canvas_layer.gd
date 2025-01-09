extends CanvasLayer

@onready var inventory = $InventoryGUI

func _ready() -> void:
	inventory.close()
	
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
