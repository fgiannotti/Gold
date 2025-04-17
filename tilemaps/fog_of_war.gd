extends Node2D

@export var map_size: Vector2i = Vector2i(1280, 1280)
@export var cell_size: int = 32
@export var reveal_radius: int = 1

var fog_texture: ImageTexture
var fog_image: Image
var explored_texture: ImageTexture
var explored_image: Image
var is_ready: bool = false

func _ready():
	fog_image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color(0.0, 0.0, 0.0, 1.0))  # Negro completamente opaco
	
	explored_image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	explored_image.fill(Color(0.0, 0.0, 0.0, 1.0))  # Inicialmente igual a la niebla

	fog_texture = ImageTexture.new()
	fog_texture.set_image(fog_image)

	explored_texture = ImageTexture.new()
	explored_texture.set_image(explored_image)

	$FogOverlay.texture = fog_texture
	is_ready = true

func _process(delta: float) -> void:
	update_fog(PlayerManager.actual_global_position)

func update_fog(position: Vector2):
	if not is_ready or fog_image == null or fog_texture == null:
		push_error("Fog system not ready.")
		return

	var center_cell = Vector2i(position / cell_size)
	var updated: bool = false

	for x in range(-reveal_radius * 2, reveal_radius * 2 + 1):
		for y in range(-reveal_radius * 2, reveal_radius * 2 + 1):
			var pos = center_cell + Vector2i(x, y)
			var pixel_pos = pos * cell_size

			for i in range(cell_size):
				for j in range(cell_size):
					var px = pixel_pos.x + i
					var py = pixel_pos.y + j

					if px >= 0 and px < map_size.x and py >= 0 and py < map_size.y:
						var current_pixel = fog_image.get_pixel(px, py)
						var in_vision = abs(x) <= reveal_radius and abs(y) <= reveal_radius  

						if in_vision:
							# 🔹 Guarda lo que había antes en la imagen explorada
							explored_image.set_pixel(px, py, get_world_pixel_color(px, py) * 0.5)  
							# 🔹 Hacer el área completamente visible
							fog_image.set_pixel(px, py, Color(0, 0, 0, 0))
							updated = true
						elif not in_vision and current_pixel.a == 0.0:
							# 🔹 Fuera del radio pero ya visto → Usar imagen explorada
							fog_image.set_pixel(px, py, explored_image.get_pixel(px, py))
							updated = true

	if updated:
		fog_texture.set_image(fog_image)

func get_world_pixel_color(x: int, y: int) -> Color:
	# 📸 Aquí puedes obtener el color real del mapa en esas coordenadas (ajustar según tu mapa)
	return Color(1.0, 1.0, 1.0, 1.0)  # 🔴 CAMBIAR: Aquí deberías obtener el color real del terreno
