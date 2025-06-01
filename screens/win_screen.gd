extends Control

@onready var win_text = $Control/WinText
@onready var results = $Control/Results
@onready var stats_container = $Control/StatsContainer
@onready var buttons_container = $Control/ButtonsContainer
@onready var animation_player = $AnimationPlayer

var stats_data = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide elements initially for animation
	win_text.modulate.a = 0.0
	results.modulate.a = 0.0
	stats_container.modulate.a = 0.0
	buttons_container.modulate.a = 0.0
	
	# Collect comprehensive stats
	collect_game_stats()
	display_results()
	
	# Play entrance animation
	play_entrance_animation()

func collect_game_stats():
	stats_data = {
		"gold": PlayerManager.gold,
		"time": InteractionManager.get_total_time(),
		"health": PlayerManager.health,
		"food": PlayerManager.food,
		"floor_reached": 3,  # Since they won, they reached floor 3
		"items_collected": get_inventory_item_count(),
		"breakables_destroyed": GameStats.get_stat("breakables_destroyed"),
		"minerals_mined": GameStats.get_stat("minerals_mined"),
		"enemies_defeated": GameStats.get_stat("enemies_defeated"),
		"damage_taken": GameStats.get_stat("damage_taken"),
		"healing_received": GameStats.get_stat("healing_received")
	}

func get_inventory_item_count() -> int:
	# Use the safely stored inventory count from PlayerManager
	# This is stored before scene transitions to avoid accessing freed objects
	return PlayerManager.get_final_inventory_count()

func get_stat_or_default(stat_name: String, default_value: int) -> int:
	# This could be expanded if you add a stats tracking system
	# For now, return default values
	return default_value

func display_results():
	# Record the win
	GameStats.player_won()
	
	# Main win message with celebration
	win_text.text = "[center][wave amp=30 freq=2.0][color=gold]🎉 VICTORY! 🎉[/color][/wave][/center]"
	
	# Comprehensive results
	var results_text = "[center][color=lime]DUNGEON CONQUERED![/color][/center]\n\n"
	results_text += "[color=yellow]📊 FINAL STATISTICS[/color]\n"
	results_text += "━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
	results_text += "💰 Gold Collected: [color=gold]%d G[/color]\n" % stats_data.gold
	results_text += "⏱️ Total Time: [color=cyan]%s[/color]\n" % stats_data.time
	results_text += "🏥 Health Remaining: [color=red]%.0f/100[/color]\n" % stats_data.health
	results_text += "🍖 Food Remaining: [color=orange]%.0f/100[/color]\n" % stats_data.food
	results_text += "🏢 Floors Completed: [color=purple]%d/3[/color]\n" % stats_data.floor_reached
	results_text += "📦 Items Collected: [color=white]%d[/color]\n" % stats_data.items_collected
	results_text += "⛏️ Minerals Mined: [color=brown]%d[/color]\n" % stats_data.minerals_mined
	results_text += "💥 Breakables Destroyed: [color=gray]%d[/color]\n" % stats_data.breakables_destroyed
	
	# Additional combat stats if any
	if stats_data.enemies_defeated > 0:
		results_text += "⚔️ Enemies Defeated: [color=red]%d[/color]\n" % stats_data.enemies_defeated
	if stats_data.damage_taken > 0:
		results_text += "💔 Damage Taken: [color=darkred]%d[/color]\n" % stats_data.damage_taken
	if stats_data.healing_received > 0:
		results_text += "💚 Healing Received: [color=green]%d[/color]\n" % stats_data.healing_received
	
	# Performance rating
	var rating = calculate_performance_rating()
	results_text += "\n[color=yellow]🌟 PERFORMANCE: %s[/color]" % rating
	
	results.text = results_text
	
	# Update stats display
	update_stats_display()

func calculate_performance_rating() -> String:
	var score = 0
	
	# Time bonus (faster = better)
	var time_parts = stats_data.time.split(":")
	var total_seconds = int(time_parts[0]) * 60 + int(time_parts[1])
	if total_seconds < 300: score += 3  # Under 5 minutes = excellent
	elif total_seconds < 600: score += 2  # Under 10 minutes = good
	elif total_seconds < 900: score += 1  # Under 15 minutes = okay
	
	# Health bonus
	if stats_data.health > 80: score += 2
	elif stats_data.health > 50: score += 1
	
	# Gold bonus
	if stats_data.gold > 200: score += 2
	elif stats_data.gold > 100: score += 1
	
	# Items bonus
	if stats_data.items_collected > 10: score += 1
	
	match score:
		8, 9: return "[color=gold]LEGENDARY[/color] ⭐⭐⭐⭐⭐"
		6, 7: return "[color=purple]EPIC[/color] ⭐⭐⭐⭐"
		4, 5: return "[color=blue]GREAT[/color] ⭐⭐⭐"
		2, 3: return "[color=green]GOOD[/color] ⭐⭐"
		_: return "[color=white]COMPLETE[/color] ⭐"

func update_stats_display():
	# You can add individual stat displays here if needed
	pass

func play_entrance_animation():
	# Create tweens for smooth entrance animations
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animate win text
	tween.tween_property(win_text, "modulate:a", 1.0, 0.8)
	tween.tween_property(win_text, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(win_text, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.5)
	
	# Animate results with delay
	tween.tween_property(results, "modulate:a", 1.0, 1.0).set_delay(0.8)
	tween.tween_property(results, "position:y", results.position.y - 20, 0.5).set_delay(0.8)
	tween.tween_property(results, "position:y", results.position.y, 0.3).set_delay(1.3)
	
	# Animate stats container
	tween.tween_property(stats_container, "modulate:a", 1.0, 0.5).set_delay(1.5)
	
	# Animate buttons
	tween.tween_property(buttons_container, "modulate:a", 1.0, 0.5).set_delay(2.0)

func _process(delta):
	$Control/ColorRect.size = get_viewport_rect().size

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER, KEY_SPACE:
				restart_game()
			KEY_ESCAPE:
				quit_to_menu()

func restart_game():
	# Add transition effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	PlayerManager.restart()
	get_tree().change_scene_to_file("res://screens/world.tscn")

func quit_to_menu():
	# This would go to a main menu if you have one
	print("Quit to menu requested")
	get_tree().quit()
