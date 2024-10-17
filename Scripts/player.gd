class_name  Player
extends CharacterBody2D

@onready var light_cone: PointLight2D = $Sprite/Gun/LightCone
@onready var light_area: PointLight2D = get_node('/root/Main/LightArea')

const BASE_LIGHT_CONE_POSITION = 1536

@export var base_max_health: float = 100
@export var base_health_regen: float = 1
@export var base_attack: float = 10
@export var base_attack_speed: float = 0.45
@export var base_light_area_size: float = 1.0
@export var base_light_cone_size: Vector2 = Vector2(11.25, 15)
@export var base_cannon_size: float = 5.0

# Explosive
var is_explosion: bool = false
@export var explosion_chance: float = 0:
	set(value):
		explosion_chance = min(value, 100)
		if explosion_chance > 0:
			is_explosion = true
		else: is_explosion = false
@export var explosion_damage_multiplier: float = 1.0

# Flare
var is_flare: bool = false
@export var flare_launch_chance: float = 0:
	set(value):
		flare_launch_chance = min(value, 100)
		is_flare = true if flare_launch_chance > 0 else false
var base_flare_size: Vector2 = Vector2(0.5,0.5)
@export var flare_size: Vector2 = Vector2(0.5,0.5)
var flare_lifetime: float = 4.0
var flare_damage: float = 5

@export var double_shot_chance: float = 0:
	set(value):
		double_shot_chance = min(value, 100)

var attack: float:
	set(value):
		attack  = value
		flare_damage = 5 * attack/100
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
var health: float:
	set(value):
		if value != max_health:
			%HealthBar.visible = true
		else: 
			%HealthBar.visible = false
		
		health = max(0, value)
		%HealthBar.value = value
var attack_speed: float:
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
	
	flare_size = base_flare_size
	
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
	var bullet: Bullet
	if is_explosion:
		if randf() < explosion_chance/100:
			bullet = BULLET_EXPLOSION.instantiate() as ExplosiveBullet
			bullet.explosion_damage_multiplier = explosion_damage_multiplier
	
	if !bullet:
		bullet = BULLET_SCENE.instantiate() as Bullet
	
	bullet.damage = attack
	bullet.piece = piece
	bullet.scale = Vector2(cannon_size, cannon_size)
	return bullet
	
func shoot(direction: Vector2):
	if is_flare and randf() < flare_launch_chance/100:
		%FlareLauncher.lauch_flare()
	
	Utils.camera.shake(1)
	%ShootSFX.playing = true
	
	var bullet = create_bullet()
	bullet.global_position = %Gun.global_position # Set Position to gun
	bullet.direction = direction
	get_node('/root/Main').add_child(bullet) # Add child to Main

func double_shot():
	var direction = global_position.direction_to(get_global_mouse_position())
	for i in range(2):
		shoot(direction.rotated(deg_to_rad(1-2*i)))

func _on_attack_interval_timeout() -> void:
	var direction = global_position.direction_to(get_global_mouse_position())
	if randf() < double_shot_chance/100:
		double_shot()
	else:
		shoot(direction)

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
			"explosion chance":
				explosion_chance = player_stats_upgrade.get(stat)
			"explosion damage multiplier":
				explosion_damage_multiplier = 1 + player_stats_upgrade.get(stat)/100
			"double shot chance":
				double_shot_chance = player_stats_upgrade.get(stat)
			"flare size": 
				flare_size = base_flare_size *  (1 +player_stats_upgrade.get(stat)/100)
			"flare launch chance":
				flare_launch_chance = player_stats_upgrade.get(stat)
			
func _on_health_regen_interval_timeout() -> void:
	health = max(max_health, health+health_regen)
