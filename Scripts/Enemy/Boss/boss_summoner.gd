extends Enemy

const MINION = preload("res://Scripts/Enemy/minion.tscn")

var is_summoning: bool = false
var minions_count: int = 5

func _ready() -> void:
	health = enemy_resource.health * health_multiplier * global_health_multiplier
	damage = enemy_resource.damage * damage_multiplier * global_damage_multiplier
	
	%SummonTimer.wait_time = randf_range(7.0, 10.0)
	%SummonTimer.start()
	$AnimatedSprite2D.play("default")

func summon():
	is_summoning = true
	
	await get_tree().create_timer(1.0).timeout
	var main = get_node("/root/Main") as GameMain
	main.remaining_enemy += minions_count
	for i in range(minions_count):
		var minion = MINION.instantiate() as Enemy
		
		var minion_position = Vector2(randf_range(-110, 110), randf_range(-80,80)) 
		minion.global_position = minion_position + global_position 
		get_node("/root/Main").call_deferred("add_child", minion)
		await get_tree().create_timer(0.2).timeout
		
	await get_tree().create_timer(0.5).timeout
	is_summoning = false
	
	%SummonTimer.wait_time = randf_range(7.0, 10.0)
	%SummonTimer.start()

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	if direction.x < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
	
	if is_summoning:
		return
	
	velocity = direction * move_speed
	
	move_and_slide()

func _on_summon_timer_timeout() -> void:
	summon()
	
