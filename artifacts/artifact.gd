class_name Artifact extends Control

@export var artifact: ArtifactInfo
@onready var hoverInfo = $VBoxContainer

func create(artifact: ArtifactInfo):
	self.artifact = artifact
	$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Title.text = artifact.title
	$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Description.text = artifact.description
	$TextureRect.texture = artifact.texture
	
var mouse_on_item = false

func _on_texture_rect_mouse_entered() -> void:
	print('[Slot] mouse on item ', self.name)
	mouse_on_item = true
	if artifact: hoverInfo.show()

func _on_texture_rect_mouse_exited() -> void:
	print('[Slot] mouse left item ', self.name)
	mouse_on_item = false
	hoverInfo.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
