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


func _on_player_health_updated(value):
	print('[HealthBar] health bar update called' , value)
	var prev_health = self.health
	
	
	self.health = min(self.max_value, value)
	print('[HealthBar] before if ' , health)
	# Took damages
	background_bar.value = self.health

	self.value = health


func _on_value_changed(value: float) -> void:
	if value <= 0:
		print('[HealthBar] emitting dead')
		player_died.emit()
		
