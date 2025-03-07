class_name HealthBar extends ProgressBar

@onready var background_bar = $BackgroundBar

signal player_died

var health = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass

func init_health(_health):
	self.health = _health
	self.max_value = _health
	self.value = _health
	
	background_bar.max_value = _health
	background_bar.value = _health


func update_health(value):
	print('[HealthBar] health bar update called' , value)
	var prev_health = self.health
	
	
	self.health = min(self.max_value, value)
	print('[HealthBar] before if ' , health)

	self.value = health
	change_background_value()

func _on_value_changed(value: float) -> void:
	if value <= 0:
		print('[HealthBar] emitting dead')
		player_died.emit()
		

var ongoing_animation = false

func change_background_value():
	if ongoing_animation: return
	
	ongoing_animation = true
	var track_idx = 0
	var anim = $AnimationPlayer.get_animation("drop") # Fetch first animation
	if anim:
		var initial_keyframe_index = 0
		var from_value = background_bar.value # health before dmg 
		var final_keyframe_index = 1
		var to_value = self.health # health after damage
		anim.track_set_key_value(track_idx, initial_keyframe_index, from_value)
		anim.track_set_key_value(track_idx, final_keyframe_index, to_value)

		   
		$AnimationPlayer.play("drop")
		await $AnimationPlayer.animation_finished
	background_bar.value = self.health
	ongoing_animation = false
