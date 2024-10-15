class_name InventorySlot
extends Panel

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
	item.position = Vector2(7, 3)
	item.scale = Vector2(1.5, 1.5)
	var inventory_node = find_parent("Inventory")
	if item in inventory_node.get_children():
		inventory_node.call_deferred("remove_child", item)
	call_deferred("add_child", item)

func unlocked():
	locked = false
