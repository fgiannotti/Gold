extends Control

signal opened
signal closed

var isOpen: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open():
	self.visible = true
	self.isOpen = true
	opened.emit()

func close():
	self.visible = false
	self.isOpen = false
	closed.emit()
