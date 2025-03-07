extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func trigger_veil_screen():
	$ColorRect.show()
	$AnimationPlayer.play("pop_black")
	await $AnimationPlayer.animation_finished

func trigger_unveil_screen():
	$ColorRect.show()
	$AnimationPlayer.play("unpop_black")
	await $AnimationPlayer.animation_finished
	$ColorRect.hide()

func trigger_lose():
	print('[SceneTransitioner] triggering lose')
	$ColorRect.show()
	$AnimationPlayer.play("pop_black")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://screens/lose_screen.tscn")
	
func trigger_win():
	print('[SceneTransitioner] triggering win')
	$ColorRect.show()
	$AnimationPlayer.play("pop_black")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://screens/win_screen.tscn")
