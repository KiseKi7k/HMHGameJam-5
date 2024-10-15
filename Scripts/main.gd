class_name GameMain
extends Node2D

var wave: int = 1

const ENEMY_SCENE: PackedScene = preload("res://Scenes/enemy.tscn")
@export var enemy_resouces: Array[EnemyResource]
	
func new_game() -> void:
	print("เริ่มเกม")
	pass

func spawn_enemy() -> void:
	var new_enemy = ENEMY_SCENE.instantiate() as Enemy
	%EnemySpawnMarker.progress_ratio = randf() # Use path follow2D to random spawn position
	new_enemy.global_position = %EnemySpawnMarker.global_position
	call_deferred("add_child", new_enemy)

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
