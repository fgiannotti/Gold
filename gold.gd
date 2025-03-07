extends RichTextLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gold = PlayerManager.gold
	self.text = "[img=40x40]res://assets/inventory/coin-basic.png[/img] Gold: " + str(gold) 
