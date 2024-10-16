class_name StartMenu
extends Control

func _on_start_button_pressed() -> void:
	Utils.game_start.emit()
	
	visible = false
