class_name StartMenu
extends Control

func _ready() -> void:
	if Utils.on_fullscreen:
		%FullscreenBox.button_pressed = true
	else:
		%FullscreenBox.button_pressed = false

func _on_start_button_pressed() -> void:
	Utils.game_start.emit()
	
	visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_fullscreen_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Utils.on_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Utils.on_fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
