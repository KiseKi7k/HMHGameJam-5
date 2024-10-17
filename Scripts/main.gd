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

const ENEMY_SCENE = preload("res://Scripts/Enemy/enemy.tscn")
@export var enemy_resouces: Array[EnemyResource]
@export var boss_list: Array[PackedScene]

var start_song = preload("res://Sound/Song.mp3")
var main_bgm = preload("res://Sound/MainBGM.mp3")
var wave_start_sfx = preload("res://Sound/WaveStartSFX.mp3")

func _ready() -> void:
	%Song.stream = start_song
	%Song.playing = true
	%Camera2D.zoom = Vector2(1.8,1.8)
	%CanvasModulate.color = Color(0,0,0)
	
	Utils.on_menu = true
	Utils.enemy_die.connect(_on_enemy_die)
	Utils.wave_start.connect(_on_wave_start)
	Utils.wave_end.connect(_on_wave_end)
	Utils.game_start.connect(_on_game_start)
	Utils.game_over.connect(_on_game_over)

func _on_game_start():
	Utils.is_game_over = false
	%Song.stream = main_bgm
	%Song.playing = true
	%Song.volume_db = -10
	
	%BtnPaused.visible = true
	
	%AnimationPlayer.play("start_game")
	Utils.on_menu = false
	await get_tree().create_timer(5.0).timeout
	Utils.wave_start.emit()
	
	%RemainingEnemyLabel.visible = true
	%WaveLabel.visible = true

func _on_game_over():
	%BtnPaused.visible = false
	%AnimationPlayer.play("game_over")
	Utils.on_menu = true
	Utils.is_game_over = true

func _on_wave_start():
	%SFX.stream = wave_start_sfx
	%SFX.playing = true
	
	wave += 1
	Utils.on_menu = false
	await get_tree().create_timer(0.5).timeout
	%AnimationPlayer.play("new_wave")
	await %AnimationPlayer.animation_finished
	
	enemy_amounts = wave + randi_range(2, 5) + wave*1.5
	remaining_enemy = enemy_amounts
	%EnemySpawnTimer.start()
	
	if wave % 10 == 0:
		spawn_boss()
	elif wave % 5 == 0:
		spawn_miniboss()
		Enemy.global_health_multiplier += 0.4
		Enemy.global_damage_multiplier += 0.1
		%EnemySpawnTimer.wait_time = max(0.5, %EnemySpawnTimer.wait_time - 0.05)

func _on_wave_end():
	Utils.on_menu = true
	%RemainingEnemyLabel.visible = false
	%WaveLabel.visible = false

func spawn_enemy() -> void:
	enemy_amounts -= 1
	if enemy_amounts <= 0:
		%EnemySpawnTimer.stop()
	
	var new_enemy = ENEMY_SCENE.instantiate() as Enemy
	new_enemy.enemy_resource = enemy_resouces.pick_random()
	add_to_main(new_enemy)

func spawn_miniboss() -> void:
	remaining_enemy += 1
	var miniboss = ENEMY_SCENE.instantiate() as Enemy
	miniboss.enemy_resource = enemy_resouces.pick_random()
	miniboss.scale *= 3
	miniboss.health_multiplier = 3
	miniboss.damage_multiplier = 1.5
	miniboss.shake_strength = 5
	add_to_main(miniboss)

func spawn_boss() -> void:
	remaining_enemy += 1
	var boss_scene = boss_list.pick_random() as PackedScene
	var boss = boss_scene.instantiate() as Enemy
	add_to_main(boss)
	
func add_to_main(enemy: Enemy) -> void:
	%EnemySpawnMarker.progress_ratio = randf()
	enemy.global_position = %EnemySpawnMarker.global_position
	call_deferred("add_child", enemy)


func _on_enemy_die():
	remaining_enemy -= 1
	if remaining_enemy <= 0:
		Utils.camera.shake(10)
		Engine.time_scale = 0.6
		await get_tree().create_timer(1.3).timeout
		Engine.time_scale = 1.0
		Utils.wave_end.emit()

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func _on_btn_paused_pressed() -> void:
	%PausedMenu.visible = true
	Utils.on_menu = true
	get_tree().paused = true


func _on_btn_continue_pressed() -> void:
	get_tree().paused = false
	%PausedMenu.visible = false
	Utils.on_menu = false


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
