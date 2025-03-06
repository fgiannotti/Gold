extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Control/Results.text = "Gold obtained: " + str(InteractionManager.get_player_gold())+ "G" + "\n Total time: "+InteractionManager.get_total_time()
	pass # Replace with function body.


func _process(delta):
	$Control/ColorRect.size = get_viewport_rect().size

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		Globals.restart()
		get_tree().change_scene_to_file("res://screens/world.tscn")
