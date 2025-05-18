extends Camera2D

@export var tileMapLayer: TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready():
	var mapRect = tileMapLayer.get_used_rect()
	var tileSize = tileMapLayer.get_rendering_quadrant_size()
	var worldSizeInPx = mapRect.size * tileSize
	limit_top = 0
	limit_left = 0
	limit_right = worldSizeInPx.x
	limit_bottom = worldSizeInPx.y
	print("[Camera2D] limit bottom: ", limit_bottom, " limit_right: ", limit_right)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
