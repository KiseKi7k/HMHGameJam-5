extends Enemy

const BOSS_ARROW = preload("res://Scripts/Enemy/Boss/boss_arrow.tscn")

var is_shooting: bool = false

func _ready() -> void:
	health = enemy_resource.health * health_multiplier * global_health_multiplier
	damage = enemy_resource.damage * damage_multiplier * global_damage_multiplier
	
	%ShootTimer.wait_time = randf_range(2.0, 5.0)
	%ShootTimer.start()

func shoot():
	is_shooting = true
	animated_sprite.play("shoot")

func _physics_process(_delta: float) -> void:
	
	if is_shooting:
		return
	
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	
	if is_attacking:
		%ShootTimer.stop()
	
	if direction.x < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

	move_and_slide()

func _on_shoot_timer_timeout() -> void:
	shoot()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite.stop()
	var arrow = BOSS_ARROW.instantiate()
	arrow.direction = global_position.direction_to(player.global_position)
	arrow.global_position = global_position
	arrow.look_at(player.global_position)
	
	
	get_node('/root/Main').call_deferred("add_child", arrow)
	await get_tree().create_timer(randf_range(2.0, 5.0)).timeout
	is_shooting = false
	
	%ShootTimer.wait_time = randf_range(2.0, 5.0)
	%ShootTimer.start()
	
