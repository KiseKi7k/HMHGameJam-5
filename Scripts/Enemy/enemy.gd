class_name Enemy
extends CharacterBody2D

static var global_health_multiplier: float = 1.0
static var global_damage_multiplier: float = 1.0

@onready var player: Player = get_node("/root/Main/Player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D

@export var enemy_resource: EnemyResource

var is_attacking: bool = false
var is_dead: bool = false

var shake_strength: float = 2

@onready var move_speed = enemy_resource.speed
var bonus_damage: float = 1
var is_slow: bool = false:
	set(value):
		if value:
			move_speed = enemy_resource.speed * 0.5
		else:
			move_speed = enemy_resource.speed

var health: float
var damage: float

var health_multiplier: float = 1.0
var damage_multiplier: float = 1.0

func _ready() -> void:
	health = enemy_resource.health * health_multiplier * global_health_multiplier
	damage = enemy_resource.damage * damage_multiplier * global_damage_multiplier
	
	if enemy_resource.sprite_frame:
		animated_sprite.sprite_frames = enemy_resource.sprite_frame
		animated_sprite.play("default")

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	
	if is_attacking and $AttackInterval.is_stopped():
		$AttackInterval.start()
	
	if direction.x < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

	move_and_slide()


func take_damage(damage: float) -> void:
	if is_dead:
		return
	
	Utils.camera.shake(1)
	%EnemyHitted.playing = true
	
	health = max(0, health - (damage * bonus_damage))
	# If health below 0 die
	if health <= 0:
		die()
	global_position += -global_position.direction_to(player.global_position) * 5
	
	animated_sprite.modulate = Color(1,1,1,1.7)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1,1,1,1)
	
	

func die() -> void:
	is_dead = true
	Utils.camera.shake(shake_strength)
	Utils.enemy_die.emit()
	$AnimatedSprite2D.visible = false
	$HitBox.set_deferred("disabled", true)
	%EnemyDieSFX.playing = true
	particles.emitting = true
	await particles.finished
	queue_free()

# Attack player
func _on_attack_interval_timeout() -> void:
	if is_dead:
		return
	player.take_damage(enemy_resource.damage)
