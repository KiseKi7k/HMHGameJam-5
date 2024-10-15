extends Node

signal wave_start()
signal wave_end()
signal send_player_upgrade_data(player_stats_upgrade: Dictionary)
signal enemy_die()

static var on_menu: bool = false

func _ready() -> void:
	ItemResource.load_resource()
