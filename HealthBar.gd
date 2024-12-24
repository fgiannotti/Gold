extends ProgressBar

@onready var timer = $Timer
@onready var background_bar = $BackgroundBar

var food = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	#print('[fbar] print heal bar', self.food)
	#print('[fbar] print heal value', self.value)
	#print('[fbar] print heal bar', self.max_value)
	pass

func init_food(_food):
	self.food = _food
	self.max_value = _food
	self.value = _food
	
	background_bar.max_value = _food
	background_bar.value = _food


func _on_timer_timeout():
	# print('timer timeout')
	# background_bar.value = self.food
	pass

func _on_player_food_updated(value):
	print('[fbar] food bar update called' , value)
	var prev_food = self.food
	
	
	self.food = min(self.max_value, value)
	print('[fbar] before if ' , food)
	# Took damages
	if food < prev_food:
		timer.start()
	else:
		background_bar.value = self.food

	self.value = food
