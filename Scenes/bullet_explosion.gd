class_name ExplosiveBullet
extends Bullet

var explosion_damage_multiplier: float = 1.0
var explosion_size: Vector2 = Vector2(2,2)


func _process(delta: float) -> void:
	move(delta)
	
	%BulletSprite.self_modulate = Color(1,1,1)
	%BulletSprite.self_modulate = Color(0,0,0)

func explode():
	Utils.camera.shake(5)
	%ExplosionSFX.playing = true
	
	direction = Vector2.ZERO
	%ExplosionSprite.scale = explosion_size
	
	%BulletSprite.visible = false
	%ExplosionSprite.visible = true
	%ExplosionArea.visible = true
	
	$CPUParticles2D.emitting = true
	await $CPUParticles2D.finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		explode()

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(explosion_damage_multiplier * damage)
