class_name Flare
extends Light

var flare_size: Vector2 = Vector2(1,1):
	set(value):
		flare_size = value
		scale = value
var flare_lifetime: float:
	set(value):
		flare_lifetime = value
		%Timer.wait_time = value
var flare_damage: float
var flare_attack_interval: float = 0.3:
	set(value):
		flare_attack_interval = value
		%AttackInterval.wait_time = value

func _on_timer_timeout() -> void:
	queue_free()

func _on_attack_interval_timeout() -> void:
	var bodies: Array[Node2D] = get_overlapping_bodies()
	for body: Enemy in bodies:
		if is_instance_valid(body) and body is Enemy:
			body.take_damage(flare_damage)
		else:
			continue
