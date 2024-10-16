extends Control

func _ready() -> void:
	Utils.game_over.connect(_on_game_over)
	visible = false
	
func _on_game_over() -> void:
	visible = true
	var wave_count: int = get_node("/root/Main").wave - 1
	%WaveLabel.text = "You have survived %s waves." %str(wave_count)
	%Audio.playing = true

func _on_start_button_pressed() -> void:
	get_tree().reload_current_scene()
