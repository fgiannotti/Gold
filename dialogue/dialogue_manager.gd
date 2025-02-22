extends Control

signal dialogue_finished # To unblock the await


var dialogue_lines: Array[Dictionary] = []
var current_index: int = 0

@export var dialogue_node: Dialogue = null

func set_dialogue_ui(node: Dialogue):
	dialogue_node = node
	dialogue_node.set_visibility(false)

func start_dialogue(lines: Array[Dictionary]) -> void:
	dialogue_lines = lines
	current_index = 0
	show_next_line() # pauses until it keeps going with the _input event
	await _wait_for_dialogue_finish()

func _input(event: InputEvent) -> void:
	if dialogue_node.is_visible() and event.is_action_pressed("talk"):
		show_next_line()

func show_next_line() -> void:
	print('showing next_line...')
	if current_index < dialogue_lines.size():
		var line = dialogue_lines[current_index]
		print("dialogue_node:", dialogue_node)
		dialogue_node.set_visibility(true).set_dialogue_name(line.get("name", "")
			).set_dialogue_text(line.get("text", ""))
		current_index += 1
	else:
		dialogue_node.set_visibility(false)
		dialogue_finished.emit()

func _wait_for_dialogue_finish() -> void:
	await self.dialogue_finished
