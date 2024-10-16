class_name Light
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	
	set_collision_mask_value(2, true)
	
func debuff(enemy: Enemy, take_effect: bool=true):
	if take_effect:
		enemy.bonus_damage = 1.5
		enemy.is_slow = true
	else:
		enemy.bonus_damage = 1
		enemy.is_slow = false


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		debuff(body, true)

func _on_body_exited(body: Node2D) -> void:
	if body is Enemy:
		debuff(body, false)
