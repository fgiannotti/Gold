extends Control

class_name Dialogue
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	$NinePatchRect/Name.visible = true
	$NinePatchRect/Text.visible = true
	$NinePatchRect.visible = true

func print_text():
	print('[Dialogue] print_text: ', $NinePatchRect/Text.text)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_visibility(visible: bool)->Dialogue:
	print('[Dialogue] setting visible: ', visible)
	self.visible = visible
	$NinePatchRect/Name.visible = visible
	$NinePatchRect/Text.visible = visible
	$NinePatchRect.visible = visible
	return self

func set_dialogue_text(text:String)-> Dialogue:
	print('[Dialogue] setting text: ', text)
	$NinePatchRect/Text.text = text
	return self

func set_dialogue_name(text:String) -> Dialogue:
	print('[Dialogue] setting name: ', text)
	$NinePatchRect/Name.text = text
	return self
