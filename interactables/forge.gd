extends Node2D

var is_used: bool = false
var player_in_area: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		print("[Forge] Player entered forge area")

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false
		print("[Forge] Player left forge area")

func use_forge() -> bool:
	if is_used:
		print("[Forge] Forge has already been used")
		return false
	
	print("[Forge] Using forge!")
	is_used = true
	$AnimatedSprite.play("off")
	
	# Find and upgrade the BasedSword artifact
	upgrade_based_sword()
	
	return true

func upgrade_based_sword():
	# Look for the BaseSword artifact in the scene
	var based_sword = find_artifact_by_name("BaseSword")
	if based_sword:
		based_sword.upgrade()
		print("[Forge] Successfully upgraded BaseSword!")
	else:
		print("[Forge] Could not find BaseSword artifact to upgrade")

func find_artifact_by_name(artifact_name: String) -> Artifact:
	# Search through the scene tree for an artifact with the given name
	var root = get_tree().current_scene
	return search_for_artifact(root, artifact_name)

func search_for_artifact(node: Node, artifact_name: String) -> Artifact:
	# Check if this node is an Artifact with the correct name
	if node is Artifact and node.name == artifact_name:
		return node
	
	# Recursively search through children
	for child in node.get_children():
		var result = search_for_artifact(child, artifact_name)
		if result:
			return result
	
	return null

func can_be_used() -> bool:
	return player_in_area and not is_used
