class_name Artifact extends Control

@export var artifact: ArtifactInfo
@onready var hoverInfo = $VBoxContainer
@onready var level_text = $TextureRect/ArtifactLevel/ArtifactLevelText
@onready var level_panel = $TextureRect/ArtifactLevel
var level: int = 0

func create(artifact: ArtifactInfo):
	self.artifact = artifact
	$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Title.text = artifact.title
	$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Description.text = artifact.description
	$TextureRect.texture = artifact.texture
	update_level_display()

func upgrade():
	level += 1
	update_level_display()
	print("[Artifact] Upgraded " + (artifact.title if artifact else "Unknown Artifact") + " to level " + str(level))

func update_level_display():
	if level > 0:
		level_panel.show()
		level_text.text = "+" + str(level)

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
	# If artifact is already assigned (from scene), initialize it
	if artifact:
		$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Title.text = artifact.title
		$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Description.text = artifact.description
		$TextureRect.texture = artifact.texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
