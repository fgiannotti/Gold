extends TextureRect

@export var sight_radius := 70.0
@export var fog_color := Color(0, 0, 0, 1)
@export var explored_color := Color8(0, 0, 0, 150)

var exploration_texture: ImageTexture
var mask_size = 164
var radial_mask: Image = Image.create(mask_size, mask_size, false, Image.FORMAT_RGBA8)

@onready var player = get_parent().get_node("Player")

func _ready():
	# 1) Full-world exploration map
	var world_size = Vector2i(1280, 1280)
	var img = Image.create(world_size.x, world_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	exploration_texture = ImageTexture.create_from_image(img)
	generate_radial_mask()

	# 3) Fog layer & shader setup
	var fog_img = Image.create(world_size.x, world_size.y, false, Image.FORMAT_RGBA8)
	fog_img.fill(fog_color)
	texture = ImageTexture.create_from_image(fog_img)

	# 4) Initialize shader parameters
	material.set_shader_parameter("sight_radius", sight_radius)
	material.set_shader_parameter("fog_color", fog_color)
	material.set_shader_parameter("explored_color", explored_color)
	material.set_shader_parameter("texture_size", Vector2(world_size.x, world_size.y))

	position = Vector2.ZERO
	size = world_size

func _process(_delta):
	if not player:
		return
	stamp_gradient_at(player.global_position)

func stamp_gradient_at(global_pos: Vector2):
	var local = (global_pos - global_position) / scale
	var img = exploration_texture.get_image()
	var msize = radial_mask.get_width()
	var dest = Vector2i(local.x - msize / 2, local.y - msize / 2)
	# Blend your precomputed mask_image into the exploration map
	img.blend_rect(radial_mask,
				   Rect2i(0, 0, msize, msize),
				   dest)
	exploration_texture.update(img)

	# Update shader so the circle follows you
	material.set_shader_parameter("player_pos", local)
	material.set_shader_parameter("exploration_texture", exploration_texture)

func generate_radial_mask():
	# Define the mask properties
	var mask_radius = mask_size / 2
	var center = Vector2(mask_radius, mask_radius)
	
	# Generate the gradient by setting each pixel's opacity
	for x in range(mask_size):
		for y in range(mask_size):
			# Calculate distance from current pixel to the center
			var distance_to_center = Vector2(x, y).distance_to(center)
			
			# Convert to a percentage of the radius (0.0 = center, 1.0 = edge)
			var distance_percent = distance_to_center / mask_radius
			
			# Create opacity gradient (1.0 at center, 0.0 at edges)
			# 1 means explored, 0 means unexplored, numbers in between are a blend
			var opacity = 1.0 - distance_percent
			
			# Ensure opacity stays within valid range
			var final_opacity = clamp(opacity, 0.0, 1.0)
			
			# Set pixel with white color and calculated opacity
			radial_mask.set_pixel(x, y, Color(1, 1, 1, final_opacity))
