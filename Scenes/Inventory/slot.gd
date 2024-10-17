class_name InventorySlot
extends Panel

const NORMAL_REGION = Rect2i(256, 224, 64, 64)
const HOVER_REGION = Rect2i(416, 224, 64, 64)

@onready var atlas: AtlasTexture = get_theme_stylebox("panel").texture

@export var test_item: bool = false
var item_scene: PackedScene = preload("res://Scenes/Inventory/item.tscn")
var item: Item = null:
	set(value):
		item = value
		item_added.emit(item)
@export var locked: bool = false:
	set(value):
		locked = value
		%Locked.visible = value

signal item_added(item)

func _ready() -> void:
	atlas.region = NORMAL_REGION
	
	create_item()

func create_item():
	if test_item:
		item = item_scene.instantiate()
		item.item_resource = ItemResource.item_resoruces_list.values().pick_random()
		item.random_item_stats()
		put_into_slot(item)

func pick_from_slot():
	if not is_instance_valid(item):
		return
	remove_child(item)
	var inventory_node = find_parent("Inventory")
	inventory_node.add_child(item)
	item = null

func put_into_slot(new_item):
	if not is_instance_valid(new_item):
		return
	item = new_item
	item.position = Vector2(9, 10)
	item.scale = Vector2(1.3, 1.3)
	var inventory_node = find_parent("Inventory")
	if item in inventory_node.get_children():
		inventory_node.call_deferred("remove_child", item)
	call_deferred("add_child", item)

func unlocked():
	locked = false
