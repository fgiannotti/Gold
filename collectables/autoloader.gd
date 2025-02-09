extends Node

################################################
# This is an autoloaded node to spawn minerals
################################################
@onready var walls_tilemap = $"../TileMap/walls"
@onready var collectables_tilemap = $"../TileMap/collectables"

const WITH_MAX_MINERAL = false
const MAX_MINERAL_SPAWNED = 50
var mineral : PackedScene = preload("res://collectables/collectable.tscn")

var coals_data: Dictionary = {
	WEST_POS: preload("res://collectables/minerals/coal/mineral_data_coal_left.tres"),
	NORTH_POS: preload("res://collectables/minerals/coal/mineral_data_coal_top.tres"),
	EAST_POS: preload("res://collectables/minerals/coal/mineral_data_coal_right.tres"),
	SOUTH_POS: preload("res://collectables/minerals/coal/mineral_data_coal_bot.tres"),
}
var rubies_data: Dictionary = {
	WEST_POS: preload("res://collectables/minerals/ruby/mineral_data_ruby_left.tres"),
	NORTH_POS: preload("res://collectables/minerals/ruby/mineral_data_ruby_top.tres"),
	EAST_POS: preload("res://collectables/minerals/ruby/mineral_data_ruby_right.tres"),
	SOUTH_POS: preload("res://collectables/minerals/ruby/mineral_data_ruby_bot.tres"),
}

var diamond_data: Dictionary = {
	WEST_POS: preload("res://collectables/minerals/diamond/mineral_data_diamond_left.tres"),
	NORTH_POS: preload("res://collectables/minerals/diamond/mineral_data_diamond_top.tres"),
	EAST_POS: preload("res://collectables/minerals/diamond/mineral_data_diamond_right.tres"),
	SOUTH_POS: preload("res://collectables/minerals/diamond/mineral_data_diamond_bot.tres"),
}

var gold_data: Dictionary = {
	WEST_POS: preload("res://collectables/minerals/gold/mineral_data_gold_left.tres"),
	NORTH_POS: preload("res://collectables/minerals/gold/mineral_data_gold_top.tres"),
	EAST_POS: preload("res://collectables/minerals/gold/mineral_data_gold_right.tres"),
	SOUTH_POS: preload("res://collectables/minerals/gold/mineral_data_gold_bot.tres"),
}

var iron_data: Dictionary = {
	WEST_POS: preload("res://collectables/minerals/iron/mineral_data_iron_left.tres"),
	NORTH_POS: preload("res://collectables/minerals/iron/mineral_data_iron_top.tres"),
	EAST_POS: preload("res://collectables/minerals/iron/mineral_data_iron_right.tres"),
	SOUTH_POS: preload("res://collectables/minerals/iron/mineral_data_iron_bot.tres"),
}
var minerals_data_dict: Dictionary = {
	"coal": coals_data,
	"iron": iron_data,
	"gold": gold_data,
	"ruby": rubies_data,
	"diamond": diamond_data,
}
var rng = RandomNumberGenerator.new()
# 0 1 2 3
# S E N W
const SOUTH_POS = 0
const EAST_POS  = 1
const NORTH_POS = 2
const WEST_POS  = 3

func _on_world_ready() -> void:
	spawn_all_minerals()

func respawn_minerals():
	clear_minerals()
	spawn_all_minerals()
	
func clear_minerals():
	get_tree().call_group("minerals", "queue_free")
	
func spawn_all_minerals():
	print('spawning all minerals...')
	var mineral_count = 0
	# spawn them sequentially with a random. Then ask gpt how to do it better
	for x in range(1, walls_tilemap.MAZE_WIDTH):
		for y in range(1, walls_tilemap.MAZE_HEIGHT):
			if WITH_MAX_MINERAL && mineral_count == MAX_MINERAL_SPAWNED: return
			if rng.randi_range(1,100) > 20:
				var directions = walls_tilemap.directions_closed_at_pos(Vector2i(x,y))
				if directions == [1,1,1,1] or directions == [0,0,0,0]:
					continue
				var valid_pos = rng_until_valid_pos(directions)
				print("found valid tile to spawn mineral, coords ", Vector2i(x,y), " valid_pos: ", valid_pos)
				spawn_mineral_at_pos(Vector2i(x,y), valid_pos)
				mineral_count += 1
	
	print('minerals spawned!')
	return

'''# values set from binary mapping
const NORTH_DIR = 4
const SOUTH_DIR = 1
const EAST_DIR = 2
const WEST_DIR = 8'''
# SENW
# valid post is one of 0 to 3 for SENW
func spawn_mineral_at_pos(coords: Vector2i, valid_pos: int):
	var mineral_name = choose_mineral()
	print("chosen mineral ", mineral_name)
	var mineral_instance: Node = preload("res://collectables/minerals/mineral.tscn").instantiate()
	mineral_instance.add_to_group("minerals", true)
	mineral_instance.mineral_data = minerals_data_dict[mineral_name][valid_pos]
	print('mineral data: ', mineral_instance.mineral_data.resource_name)
	collectables_tilemap.spawn_scene_at_tile(coords, mineral_instance)
	return

func choose_mineral():
	# 5%
	if rng.randi_range(1,100) >= 95:
		return "diamond"
	# 10%
	if rng.randi_range(1,100) >= 85:
		return "ruby"
	# 20%
	if rng.randi_range(1,100) >= 65:
		return "gold"
	# 20%
	if rng.randi_range(1,100) >= 45:
		return "iron"
	# last 45%
	return "coal"

	
func rng_until_valid_pos(directions: Array[int]) -> int:
	while true:
		var position = randi_range(0,3)
		if directions[position] == 1:
			return position
	return -1
