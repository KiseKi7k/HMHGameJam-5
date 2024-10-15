class_name Enemy
extends CharacterBody2D

@onready var player: Player = get_node("/root/Main/Player")

@export var enemy_resource: EnemyResource
@onready var health = enemy_resource.health
var is_attacking: bool = false

func _ready() -> void:
	if enemy_resource:
		$Sprite.texture = enemy_resource.sprite


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * enemy_resource.speed
	
	if is_attacking and $AttackInterval.is_stopped():
		$AttackInterval.start()
	
	#TODO: flip sprite

	move_and_slide()


func take_damage(damage: float) -> void:
	health -= damage
	
	# If health below 0 die
	if health <= 0:
		die()

func die() -> void:
	queue_free()

# Attack player
func _on_attack_interval_timeout() -> void:
	player.take_damage(enemy_resource.damage)
