extends RichTextLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gold = $"../../Player".gold
	self.text = "[img=16x16]res://assets/inventory/coin-basic.png[/img] Gold: " + str(gold) 
