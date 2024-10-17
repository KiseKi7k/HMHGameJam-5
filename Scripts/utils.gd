extends Node

signal wave_start()
signal wave_end()
signal send_player_upgrade_data(player_stats_upgrade: Dictionary)
signal enemy_die()
signal game_start()
signal game_over()

const CURSOR_CLICK = preload("res://Asset/CursorClick1.png")
const CURSOR_AIM = preload("res://Asset/CursorAim2.png")

var on_menu: bool = false:
	set(value):
		on_menu = value
		if value:
			Input.set_custom_mouse_cursor(CURSOR_CLICK, Input.CURSOR_ARROW, Vector2(4,8))
		else:
			Input.set_custom_mouse_cursor(CURSOR_AIM, Input.CURSOR_ARROW, Vector2(0,0))
var is_game_over: bool = false
var on_fullscreen: bool = false

var camera: MainCamera

func _ready() -> void:
	ItemResource.load_resource()
