class_name  Player
extends CharacterBody2D

var base_max_health: float = 100
var base_attack: float = 10
var base_attack_speed: float = 0.2
var base_light_area: float = 1.0
var base_light_cone_size: float = 1.0
var base_cannon_size: float = 1.0

var max_health: float
var attack: float
var cannon_size: float
var piece: int = 1
var defence: int = 0
var light_area: float:
	set(value):
		light_area = value
		%LightArea.scale = Vector2(value, value)
var light_cone_size: float:
	set(value):
		light_cone_size = value
		%LightCone.scale = Vector2(value, value)


@export var health: float = 100
@export var attack_speed: float = 0.2:
	set(value):
		attack_speed = value
		%AttackInterval.wait_time = value

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")

func _ready() -> void:
	max_health = base_max_health
	attack = base_attack
	cannon_size = base_cannon_size
	light_area = base_light_area
	light_cone_size = base_light_cone_size
	
	
	Utils.send_player_upgrade_data.connect(_on_send_player_data)
	Utils.wave_start.connect(_on_wave_start)

func _on_wave_start():
	health = max_health

func _input(event: InputEvent) -> void:
	if Utils.on_menu:
		%AttackInterval.stop()
		return
	
	# Player input
	if event.is_action_pressed("left_click"):
		%AttackInterval.start()
	if event.is_action_released("left_click"):
		%AttackInterval.stop()
	
func shoot_bullet() -> void:
	var bullet = BULLET_SCENE.instantiate() # Create bullet instance
	bullet.global_position = $Gun/Pivot.global_position # Set Position to gun
	var direction = global_position.direction_to( get_global_mouse_position()) # Set direction
	bullet.direction = direction
	bullet.damage = attack
	bullet.piece = piece
	bullet.scale = Vector2(cannon_size, cannon_size)
	get_node('/root/Main').add_child(bullet) # Add child to Main

func _process(delta: float) -> void:
	if Utils.on_menu:
		return
	look_at(get_global_mouse_position())
	
func take_damage(damage: float) -> void:
	health -= max(0, damage-defence)
	
	if health <= 0:
		game_over()

func game_over():
	pass

# If enemy hit it activate enemy attack
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Enemy:
		var enemy: Enemy = body
		enemy.is_attacking = true

func _on_attack_interval_timeout() -> void:
	shoot_bullet()

func _on_send_player_data(player_stats_upgrade):
	apply_upgrade(player_stats_upgrade)

func apply_upgrade(player_stats_upgrade: Dictionary):
	for stat in player_stats_upgrade.keys():
		match stat.to_lower():
			"attack":
				attack = base_attack * (1+player_stats_upgrade.get(stat)/100)
			"health":
				max_health = base_max_health * (1+player_stats_upgrade.get(stat)/100)
			"piece":
				piece = 1 + player_stats_upgrade.get(stat)
			"defence":
				defence = player_stats_upgrade.get(stat)
			"cannon size":
				cannon_size = base_cannon_size * (1+player_stats_upgrade.get(stat)/100)
			"light area":
				light_area = base_light_area * (1+player_stats_upgrade.get(stat)/100)
			"light size":
				light_cone_size = base_light_cone_size * (1+player_stats_upgrade.get(stat)/100)
