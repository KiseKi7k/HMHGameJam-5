class_name UpgradeBox
extends NinePatchRect

func _ready() -> void:
	%UpgradeSlot1.item_added.connect(_on_slot_item_added)
	%UpgradeSlot2.item_added.connect(_on_slot_item_added)
	%UpgradeSlot3.item_added.connect(_on_slot_item_added)
	%BtnUpgrade.disabled = true

func item_upgradable(item1: Item, item2: Item, item3: Item) -> bool:
	if  item1.tier == item3.tier and item1.tier == item2.tier and \
	item1.item_resource.item_id == item2.item_resource.item_id and item1.item_resource.item_id == item3.item_resource.item_id:
		return true
	return false

func _on_slot_item_added(item: Item) -> void:
	var item1 = %UpgradeSlot1.item
	var item2 = %UpgradeSlot2.item
	var item3 = %UpgradeSlot3.item
	
	if is_instance_valid(item1) and is_instance_valid(item2) and is_instance_valid(item3):
		if item_upgradable(item1, item2, item3):
			%BtnUpgrade.disabled = false

func _on_btn_upgrade_pressed() -> void:
	%UpgradeSlot2.item.upgrade_tier()
	%UpgradeSlot1.item.queue_free()
	%UpgradeSlot3.item.queue_free()
	
	%ItemInfoDisplay.display_item(%UpgradeSlot2.item)
	%BtnUpgrade.disabled = true
