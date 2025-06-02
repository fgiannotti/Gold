extends Node

# Game statistics tracking
var stats = {
	"breakables_destroyed": 0,
	"minerals_mined": 0,
	"enemies_defeated": 0,
	"damage_taken": 0,
	"healing_received": 0,
	"items_collected": 0,
	"chests_opened": 0,
	"deaths": 0,
	"wins": 0
}

func _ready():
	# Reset stats at the start of each session
	reset_stats()

func reset_stats():
	for key in stats.keys():
		stats[key] = 0

func increment_stat(stat_name: String, amount: int = 1):
	if stat_name in stats:
		stats[stat_name] += amount
		print("[GameStats] %s: %d" % [stat_name, stats[stat_name]])

func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)

func get_all_stats() -> Dictionary:
	return stats.duplicate()

# Convenience functions for common events
func breakable_destroyed():
	increment_stat("breakables_destroyed")

func mineral_mined():
	increment_stat("minerals_mined")

func enemy_defeated():
	increment_stat("enemies_defeated")

func damage_taken(amount: int):
	increment_stat("damage_taken", amount)

func healing_received(amount: int):
	increment_stat("healing_received", amount)

func item_collected():
	increment_stat("items_collected")

func chest_opened():
	increment_stat("chests_opened")

func player_died():
	increment_stat("deaths")

func player_won():
	increment_stat("wins") 
