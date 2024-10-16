extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var health: float = 20
var damage: float = 25
var arrow_speed: float = 100

const RANGE: float =  2000
var travel_distance: float = 0
var direction: Vector2 = Vector2.ZERO

func move(delta) -> void:
	
	position += direction * arrow_speed * delta
	travel_distance += arrow_speed * delta
	
	if travel_distance > RANGE:
		queue_free()

func _process(delta) -> void:
	move(delta)

func take_damage(damage: float) -> void:
	health -= damage
	
	sprite.modulate = Color(1,1,1,1.7)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1,1,1,1)
	
	# If health below 0 die
	if health <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	print('hitted')
