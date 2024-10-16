extends Node

signal wave_start()
signal wave_end()
signal send_player_upgrade_data(player_stats_upgrade: Dictionary)
signal enemy_die()
signal game_start()
signal game_over()

var on_menu: bool = false
var is_game_over: bool = false

var camera: MainCamera

func _ready() -> void:
	ItemResource.load_resource()
