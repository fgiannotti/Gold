extends Control

@onready var play_button = $VBoxContainer/Buttons/PlayButton
@onready var options_button = $VBoxContainer/Buttons/OptionsButton
@onready var quit_button = $VBoxContainer/Buttons/QuitButton


func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed():
	get_tree().change_scene_to_file("res://screens/meta_game_screen.tscn")


func _on_options_pressed():
	print("Options button pressed - no action implemented yet.")
	# You can implement options screen logic here later


func _on_quit_pressed():
	get_tree().quit() 