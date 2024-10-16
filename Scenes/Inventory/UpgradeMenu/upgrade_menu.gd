class_name UpgradeMenu
extends Control
const ITEM = preload("res://Scenes/Inventory/item.tscn")

func _ready() -> void:
	Utils.wave_end.connect(_on_wave_end)
	for upgrade_container: UpgradeContainer in $HBoxContainer.get_children():
		upgrade_container.btn_select.pressed.connect(_on_upgrade_selected.bind(upgrade_container))


func _on_wave_end():
	visible = true
	%Audio.playing = true
	for upgrade_container: UpgradeContainer in $HBoxContainer.get_children():
		var item = random_item()
		upgrade_container.item = item

func random_item() -> Item:
	var new_item = ITEM.instantiate()
	new_item.item_resource = ItemResource.item_resoruces_list.values().pick_random()
	new_item.random_item_stats()
	return new_item

func _on_upgrade_selected(upgrade_container: UpgradeContainer):
	var item: Item = upgrade_container.item
	if not is_instance_valid(item):
		return
	%Inventory.quickput_to_inventory(item)
	
	visible = false
	%Inventory.visible = true
	
func _on_button_pressed() -> void:
	_on_wave_end()
