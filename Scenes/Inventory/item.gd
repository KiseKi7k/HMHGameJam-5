class_name Item
extends Node2D

@onready var texture_rect: TextureRect = $TextureRect

@export var tier: int = 0
@export var item_resource: ItemResource
var stat_values: Dictionary

func _ready() -> void:
	texture_rect.texture = item_resource.item_texture

func random_item_stats():
	var tier_multiplier = (1 + 0.5*tier)
	for i in range(0, len(item_resource.item_stat), 2):
		var key_min = item_resource.item_stat.keys()[i] 
		var key_max = item_resource.item_stat.keys()[i+1]
		
		var parts = key_min.split("_")
		var stat_name = " ".join(parts.slice(0, parts.size() - 1)).capitalize()
		var stat_value = round(randf_range(item_resource.item_stat.get(key_min) * tier_multiplier,
								item_resource.item_stat.get(key_max) * tier_multiplier)
								)
		
		stat_values[stat_name] = stat_value

func upgrade_tier():
	tier += 1
	random_item_stats()
	
	if tier > 0:
		%TierLabel.text = "+%s" %tier
