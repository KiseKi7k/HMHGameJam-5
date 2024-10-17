class_name FlareLauncher
extends Node2D

const FLARE = preload("res://Scripts/flare.tscn")

@onready var player: Player = get_node('/root/Main/Player')

func lauch_flare():
	var flare = FLARE.instantiate() as Flare
	flare.flare_damage = player.flare_damage
	flare.flare_lifetime = player.flare_lifetime
	flare.scale = player.flare_size
	
	
	var x_direction: int = 1 if randf() > 0.5 else -1 # สุ้มซ้าย ขวา
	var y_direction: int = 1 if randf() > 0.5 else -1 # สุ้มบนล่าง
	
	var flare_position = Vector2(randi_range(200,400) * x_direction,
								 randi_range(100,400) * y_direction)
	flare.global_position = flare_position
	get_node('/root/Main').call_deferred("add_child", flare)
