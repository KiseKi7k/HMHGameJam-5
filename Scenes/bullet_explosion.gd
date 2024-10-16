extends Bullet

var explosion_damage: float
var explosion_size: Vector2 = Vector2(2,2)


func _process(delta: float) -> void:
	move(delta)
	
	%BulletSprite.self_modulate = Color(1,1,1)
	%BulletSprite.self_modulate = Color(0,0,0)

func explode():
	direction = Vector2.ZERO
	%ExplosionSprite.scale = explosion_size
	
	%BulletSprite.visible = false
	%ExplosionSprite.visible = true
	%ExplosionArea.visible = true
	
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		explode()

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)