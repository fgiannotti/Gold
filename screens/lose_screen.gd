extends Control

@onready var lose_text = $Control/LoseText
@onready var failure_reason = $Control/FailureReason
@onready var retry_text = $Control/Retry
@onready var stats_summary = $Control/StatsSummary
@onready var buttons_container = $Control/ButtonsContainer

var death_cause = ""
var player_stats = {}

func _ready() -> void:
	# Hide elements initially for dramatic entrance
	lose_text.modulate.a = 0.0
	failure_reason.modulate.a = 0.0
	retry_text.modulate.a = 0.0
	stats_summary.modulate.a = 0.0
	buttons_container.modulate.a = 0.0
	
	# Determine death cause and collect stats
	determine_death_cause()
	collect_final_stats()
	update_display()
	
	# Play dramatic entrance animation
	play_death_animation()

func determine_death_cause():
	if PlayerManager.health <= 0:
		death_cause = "💀 DEATH BY COMBAT"
	elif PlayerManager.food <= 0:
		death_cause = "🍖 DEATH BY STARVATION"
	else:
		death_cause = "💥 MYSTERIOUS DEMISE"

func collect_final_stats():
	player_stats = {
		"gold": PlayerManager.gold,
		"time": InteractionManager.get_total_time(),
		"health": PlayerManager.health,
		"food": PlayerManager.food,
		"floor_reached": get_current_floor(),
		"items_collected": get_inventory_item_count(),
		"breakables_destroyed": GameStats.get_stat("breakables_destroyed"),
		"minerals_mined": GameStats.get_stat("minerals_mined"),
		"enemies_defeated": GameStats.get_stat("enemies_defeated"),
		"damage_taken": GameStats.get_stat("damage_taken"),
		"healing_received": GameStats.get_stat("healing_received")
	}

func get_current_floor() -> int:
	# Try to get the current floor from the world scene
	var world_node = get_tree().get_first_node_in_group("world")
	if world_node and world_node.has_method("get_floor"):
		return world_node.get_floor()
	elif world_node and world_node.has_variable("floor"):
		return world_node.floor
	return 1  # Default to floor 1

func get_inventory_item_count() -> int:
	# Use the safely stored inventory count from PlayerManager
	# This is stored before scene transitions to avoid accessing freed objects
	return PlayerManager.get_final_inventory_count()

func update_display():
	# Record the death
	GameStats.player_died()
	
	# Main death message with dramatic effect
	lose_text.text = "[center][shake rate=8.0 level=5][color=red]💀 GAME OVER 💀[/color][/shake][/center]"
	
	# Death cause
	var cause_text = "[center][color=orange]%s[/color][/center]" % death_cause
	if PlayerManager.health <= 0:
		cause_text += "\n[center][color=gray]Your health reached zero in the depths...[/color][/center]"
	elif PlayerManager.food <= 0:
		cause_text += "\n[center][color=gray]Hunger consumed you in the darkness...[/color][/center]"
	
	failure_reason.text = cause_text
	
	# Final statistics
	var stats_text = "[center][color=yellow]📊 FINAL STATISTICS[/color][/center]\n"
	stats_text += "━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
	stats_text += "💰 Gold Lost: [color=gold]%d G[/color]\n" % player_stats.gold
	stats_text += "⏱️ Survival Time: [color=cyan]%s[/color]\n" % player_stats.time
	stats_text += "🏢 Floor Reached: [color=purple]%d/3[/color]\n" % player_stats.floor_reached
	stats_text += "📦 Items Collected: [color=white]%d[/color]\n" % player_stats.items_collected
	stats_text += "⛏️ Minerals Mined: [color=brown]%d[/color]\n" % player_stats.minerals_mined
	stats_text += "💥 Breakables Destroyed: [color=gray]%d[/color]\n" % player_stats.breakables_destroyed
	stats_text += "🏥 Final Health: [color=red]%.0f[/color]\n" % player_stats.health
	stats_text += "🍖 Final Food: [color=orange]%.0f[/color]\n" % player_stats.food
	
	# Additional combat stats if any
	if player_stats.enemies_defeated > 0:
		stats_text += "⚔️ Enemies Defeated: [color=red]%d[/color]\n" % player_stats.enemies_defeated
	if player_stats.damage_taken > 0:
		stats_text += "💔 Damage Taken: [color=darkred]%d[/color]\n" % player_stats.damage_taken
	if player_stats.healing_received > 0:
		stats_text += "💚 Healing Received: [color=green]%d[/color]\n" % player_stats.healing_received
	
	# Add motivational message
	stats_text += "\n" + get_motivational_message()
	
	stats_summary.text = stats_text
	
	# Enhanced retry prompt
	retry_text.text = "[center][color=white][pulse freq=1.0]Press [color=yellow]ENTER[/color] to try again[/pulse][/center]\n[center][color=gray]Press [color=yellow]ESC[/color] to quit[/color][/center]"

func get_motivational_message() -> String:
	var messages = []
	
	# Floor-based messages
	if player_stats.floor_reached == 1:
		messages.append("[color=cyan]💡 Tip: Mine minerals and break boxes for supplies![/color]")
		messages.append("[color=cyan]💡 Tip: Watch your hunger and health bars![/color]")
	elif player_stats.floor_reached == 2:
		messages.append("[color=green]💪 Good progress! You made it to floor 2![/color]")
		messages.append("[color=cyan]💡 Tip: Stock up on food before advancing![/color]")
	else:
		messages.append("[color=purple]⚡ So close! Floor 3 is within reach![/color]")
	
	# Specific death cause advice
	if PlayerManager.health <= 0:
		messages.append("[color=orange]⚔️ Try to avoid unnecessary combat or use healing items![/color]")
	elif PlayerManager.food <= 0:
		messages.append("[color=orange]🍖 Remember to collect and use energy bars to survive![/color]")
	
	# Gold-based encouragement
	if player_stats.gold > 100:
		messages.append("[color=gold]💰 Great job collecting %d gold![/color]" % player_stats.gold)
	
	# Time-based encouragement
	var time_parts = player_stats.time.split(":")
	var total_seconds = int(time_parts[0]) * 60 + int(time_parts[1])
	if total_seconds > 300:
		messages.append("[color=cyan]🐌 Take your time exploring, but manage resources![/color]")
	
	# Return random message
	return messages[randi() % messages.size()]

func play_death_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Dramatic death text entrance
	tween.tween_property(lose_text, "modulate:a", 1.0, 1.0)
	tween.tween_property(lose_text, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(lose_text, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.5)
	
	# Death cause appears
	tween.tween_property(failure_reason, "modulate:a", 1.0, 0.8).set_delay(1.0)
	tween.tween_property(failure_reason, "position:y", failure_reason.position.y - 10, 0.4).set_delay(1.0)
	tween.tween_property(failure_reason, "position:y", failure_reason.position.y, 0.4).set_delay(1.4)
	
	# Stats fade in
	tween.tween_property(stats_summary, "modulate:a", 1.0, 1.0).set_delay(1.8)
	
	# Retry prompt appears last
	tween.tween_property(retry_text, "modulate:a", 1.0, 0.8).set_delay(2.6)
	tween.tween_property(buttons_container, "modulate:a", 1.0, 0.5).set_delay(3.0)

func _process(delta):
	$Control/ColorRect.size = get_viewport_rect().size

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER, KEY_SPACE:
				restart_game()
			KEY_ESCAPE:
				quit_game()

func restart_game():
	# Add fade transition
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	PlayerManager.restart()
	get_tree().change_scene_to_file("res://screens/world.tscn")

func quit_game():
	# Dramatic quit effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	get_tree().quit()
