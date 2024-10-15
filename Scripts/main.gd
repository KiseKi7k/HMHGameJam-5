class_name GameMain
extends Node2D

var wave: int = 0:
	set(value):
		wave = value
		%WaveLabel.text = "Wave %s" %str(value)
var enemy_amounts: int
var remaining_enemy: int:
	set(value):
		remaining_enemy = value
		%RemainingEnemyLabel.text = "Remaining enemies: %s" %str(value)

const ENEMY_SCENE: PackedScene = preload("res://Scenes/enemy.tscn")
@export var enemy_resouces: Array[EnemyResource]
	
func _ready() -> void:
	Utils.enemy_die.connect(_on_enemy_die)
	Utils.wave_start.connect(_on_wave_start)
	Utils.wave_end.connect(_on_wave_end)
	Utils.wave_start.emit()

func _on_wave_start():
	Utils.on_menu = false
	wave += 1
	enemy_amounts = 1
	remaining_enemy = enemy_amounts
	%EnemySpawnTimer.start()

func _on_wave_end():
	Utils.on_menu = true

func spawn_enemy() -> void:
	enemy_amounts -= 1
	if enemy_amounts <= 0:
		%EnemySpawnTimer.stop()
	
	var new_enemy = ENEMY_SCENE.instantiate() as Enemy
	%EnemySpawnMarker.progress_ratio = randf() # Use path follow2D to random spawn position
	new_enemy.global_position = %EnemySpawnMarker.global_position
	call_deferred("add_child", new_enemy)

func _on_enemy_die():
	remaining_enemy -= 1
	if remaining_enemy <= 0:
		Utils.wave_end.emit()

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
