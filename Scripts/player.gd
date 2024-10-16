class_name  Player
extends CharacterBody2D

@onready var light_cone: PointLight2D = $Sprite/Gun/LightCone
@onready var light_area: PointLight2D = get_node('/root/Main/LightArea')

const BASE_LIGHT_CONE_POSITION = 1536

var base_max_health: float = 100
var base_health_regen: float = 1
var base_attack: float = 10
var base_attack_speed: float = 0.45
var base_light_area_size: float = 1.0
var base_light_cone_size: Vector2 = Vector2(11.25, 15)
var base_cannon_size: float = 5.0

# Explosive
var is_explosion: bool = false
var explosion_chance: float

# Flare
var is_flare: bool = false:
	set(value):
		is_flare = value
		if value:
			%FlareLaucher.visible = true
		else:
			%FlareLaucher.visible = false
var flare_size: Vector2 = Vector2(1,1)
var flare_lifetime: float = 4.0
var flare_damage: float = 5

var attack: float
var cannon_size: float
var piece: int = 0
var defence: int = 0
var light_area_size: float:
	set(value):
		light_area_size = value
		light_area.scale = Vector2(value, value)
var light_cone_size: Vector2:
	set(value):
		light_cone_size = value
		light_cone.scale = value
		light_cone.position

var max_health: float:
	set(value):
		max_health = value
		%HealthBar.max_value = value
var health_regen: float
@export var health: float:
	set(value):
		if value != max_health:
			%HealthBar.visible = true
		else: 
			%HealthBar.visible = false
		
		health = max(0, value)
		%HealthBar.value = value
@export var attack_speed: float:
	set(value):
		attack_speed = max(0.08, value)
		%AttackInterval.wait_time = attack_speed

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")
const BULLET_EXPLOSION = preload("res://Scenes/bullet_explosion.tscn")

func _ready() -> void:
	max_health = base_max_health
	attack = base_attack
	attack_speed = base_attack_speed
	cannon_size = base_cannon_size
	light_area_size = base_light_area_size
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

func create_bullet() -> Bullet:
	if is_explosion:
		if randf() < explosion_chance:
			return BULLET_EXPLOSION.instantiate()
	return BULLET_SCENE.instantiate()
	
func shoot():
	Utils.camera.shake(0.5)
	%ShootSFX.playing = true
	
	var bullet = create_bullet()
	bullet.global_position = %Gun.global_position # Set Position to gun
	var direction = global_position.direction_to( get_global_mouse_position()) # Set direction
	bullet.direction = direction
	bullet.damage = attack
	bullet.piece = piece
	bullet.scale = Vector2(cannon_size, cannon_size)
	get_node('/root/Main').add_child(bullet) # Add child to Main

func _process(_delta: float) -> void:
	if Utils.on_menu:
		return
	var direction = (get_global_mouse_position() - %Gun.global_position).normalized()
	%Gun.rotation = direction.angle() + 3 *PI /2
	
func take_damage(damage: float) -> void:
	if Utils.is_game_over:
		return
	
	%PlayerHittedSFX.playing = true
	Utils.camera.shake(2.5)
	health -= max(0, damage-defence)
	
	%Sprite.modulate = Color(1,1,1,1.7)
	await get_tree().create_timer(0.1).timeout
	%Sprite.modulate = Color(1,1,1,1)
	
	if health <= 0:
		game_over()

func game_over():
	Utils.game_over.emit()

# If enemy hit it activate enemy attack
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Enemy:
		var enemy: Enemy = body
		enemy.is_attacking = true

func _on_attack_interval_timeout() -> void:
	shoot()

func _on_send_player_data(player_stats_upgrade):
	apply_upgrade(player_stats_upgrade)

func apply_upgrade(player_stats_upgrade: Dictionary):
	for stat in player_stats_upgrade.keys():
		match stat.to_lower():
			"attack":
				attack = base_attack * (1+player_stats_upgrade.get(stat)/100)
			"attack speed":
				attack_speed = base_attack_speed - (player_stats_upgrade.get(stat)/1000)
			"health":
				max_health = base_max_health * (1+player_stats_upgrade.get(stat)/100)
			"piece":
				piece = 1 + player_stats_upgrade.get(stat)
			"defence":
				defence = player_stats_upgrade.get(stat)
			"cannon size":
				cannon_size = base_cannon_size * (1+player_stats_upgrade.get(stat)/100)
			"light area":
				light_area_size = base_light_area_size * (1+player_stats_upgrade.get(stat)/100)
			"light size":
				light_cone_size = base_light_cone_size * (1+player_stats_upgrade.get(stat)/100)
				light_cone.position.y = BASE_LIGHT_CONE_POSITION * (1+player_stats_upgrade.get(stat)/100)
			"health regen":
				health_regen = health_regen + base_health_regen
			
func _on_health_regen_interval_timeout() -> void:
	health = max(max_health, health+health_regen)
