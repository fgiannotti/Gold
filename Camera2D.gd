extends Camera2D

@export var tilemap: TileMap
# Called when the node enters the scene tree for the first time.
func _ready():
	var mapRect = tilemap.get_used_rect()
	var tileSize = tilemap.cell_quadrant_size
	var worldSizeInPx = mapRect.size * tileSize
	limit_top = 0
	limit_left = 0
	limit_right = worldSizeInPx.x
	limit_bottom = worldSizeInPx.y
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
