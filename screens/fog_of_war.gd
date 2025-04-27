# fog_of_war.gd (adjuntar al TextureRect hijo de World)
extends TextureRect

@export var exploration_radius := 50.0  # Radio en tiles
@export var fog_color := Color(0, 0, 0, 1)
@export var explored_color := Color(0.3, 0.3, 0.3, 0.8)

@onready var player = get_parent().get_node("Player")  # Ajusta esta ruta
@onready var world = get_parent()

var fog_texture : ImageTexture
var exploration_texture : ImageTexture

func _ready():
	# 1. Configurar tamaño para cubrir TODO el mundo
	var texture_size = Vector2i(1280, 1280)  # Resolución fija (ajustable)

	
	# 2. Crear texturas
	var fog_image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
	fog_image.fill(fog_color)
	fog_texture = ImageTexture.create_from_image(fog_image)
	
	var explore_image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
	explore_image.fill(Color(0, 0, 0, 0))
	exploration_texture = ImageTexture.create_from_image(explore_image)
	
	# 3. Configurar material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://screens/FOW.gdshader")
	shader_material.set_shader_parameter("exploration_texture", exploration_texture)
	shader_material.set_shader_parameter("fog_color", fog_color)
	shader_material.set_shader_parameter("explored_color", explored_color)
	shader_material.set_shader_parameter("texture_size", texture_size)
	material = shader_material
	texture = fog_texture

func _process(delta):
	if player:
		update_fog(player.global_position)

func update_fog(player_pos):
	var local_pos = (player_pos - global_position) / scale
	var explore_img = exploration_texture.get_image()
	var new_explore = Image.create(explore_img.get_width(), explore_img.get_height(), false, Image.FORMAT_RGBA8)
	new_explore.copy_from(explore_img)
	update_explore_img(Vector2i(local_pos), new_explore)

	exploration_texture.update(new_explore)
	print('sending player_pos ', local_pos, 'texture ',   exploration_texture.get_size())
	
	material.set_shader_parameter("player_pos", local_pos)
	material.set_shader_parameter("exploration_texture", exploration_texture)
	material.set_shader_parameter("radius", exploration_radius)

func update_explore_img(center: Vector2i, explore_img: Image):
	for x in range(center.x - exploration_radius, center.x + exploration_radius + 1):
		for y in range(center.y - exploration_radius, center.y + exploration_radius + 1):
			if x >= 0 and y >= 0 and x < explore_img.get_width() and y < explore_img.get_height():
				if Vector2(x - center.x, y - center.y).length() <= exploration_radius:
					explore_img.set_pixel(x, y, explored_color)  # Usar blanco para marca de exploración
	
