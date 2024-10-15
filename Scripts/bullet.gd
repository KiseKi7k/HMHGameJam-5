extends Area2D

var bullet_speed: float = 400  # ความเร็วของกระสุน
var direction: Vector2 = Vector2.ZERO  # ทิศทางของกระสุน
var damage: float

const RANGE: float =  1000
var travel_distance: float = 0

func _process(delta) -> void:
	# เคลื่อนที่กระสุนไปในทิศทางที่กำหนด
	position += direction * bullet_speed * delta
	travel_distance += bullet_speed * delta
	# ลบกระสุนหากมันออกไปนอกขอบหน้าจอ
	if travel_distance > RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
