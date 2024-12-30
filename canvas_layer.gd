extends CanvasLayer

@onready var inventory = $Inventory
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
