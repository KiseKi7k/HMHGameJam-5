class_name  Player
extends CharacterBody2D

@export var health: float = 100
@export var damage: float = 10
@export var attack_speed: float = 0.2:
	set(value):
		attack_speed = value
		%AttackInterval.wait_time = value

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")

func _input(event: InputEvent) -> void:
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
	bullet.damage = damage 
	get_node('/root/Main').add_child(bullet) # Add child to Main

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
func take_damage(damage: float) -> void:
	health -= damage
	
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
