class_name FoodBar extends ProgressBar

@onready var background_bar = $BackgroundBar

signal player_starved

var food = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_value_changed(value: float) -> void:
	print('[FoodBar] changed value ', value)
	if value <= 0:
		print('[FoodBar] emitting starved')
		# TODO: Make starvation happen faster calling singleton
		player_starved.emit()

func _process(delta):
	pass

func init_food(_food):
	self.food = _food
	self.max_value = _food
	self.value = _food
	
	background_bar.max_value = _food
	background_bar.value = _food

func update_food(value):
	print('[FoodBar] food bar update called' , value)
	var prev_food = self.food
	
	self.food = min(self.max_value, value)
	PlayerManager.food = self.food
	self.value = self.food


func _on_timer_timeout() -> void:
	background_bar.value = self.food
