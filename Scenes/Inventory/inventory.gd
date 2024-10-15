class_name Inventory
extends Control

var player_item_stat: Dictionary

var holding_item: Node2D = null
var last_pick_slot: InventorySlot = null
var hover_slot: InventorySlot = null
var selected_slot: InventorySlot = null:
	set(value):
		selected_slot = value
		if is_instance_valid(selected_slot.item):
			%ItemInfoDisplay.display_item(selected_slot.item)

func _ready() -> void:
	connect_slot($InventorySlot/SlotContainers)
	connect_slot($EquipedItemSlot/SlotContainers)
	connect_slot($UpgradeBox/SlotContainer)

func connect_slot(parent_node: Control): # Connect signal to slots
	for inv_slot: InventorySlot in parent_node.get_children():
		inv_slot.gui_input.connect(slot_gui_input.bind(inv_slot))
		inv_slot.mouse_entered.connect(_on_slot_mouse_entered.bind(inv_slot))
		inv_slot.mouse_exited.connect(_on_slot_mouse_exited.bind(inv_slot))

func _on_slot_mouse_entered(slot):
	hover_slot = slot
	# Make slot Bigger? indicate hover

func _on_slot_mouse_exited(slot):
	if hover_slot == slot:
		hover_slot = null
	# Make slot return to normal

func slot_gui_input(event: InputEvent, slot: InventorySlot):
	if event is InputEventMouseButton:
		if event.is_action_released("left_click"):
			if holding_item:
				if hover_slot and !hover_slot.locked:
					if not hover_slot.item: # If empty slot -> put item into that slot
						hover_slot.put_into_slot(holding_item)
						
					else: # If slot is not empty -> swap item with that slot
						var temp_item = hover_slot.item
						hover_slot.pick_from_slot()
						hover_slot.put_into_slot(holding_item)
						last_pick_slot.put_into_slot(temp_item)
					
				else: # If don't drop item on slot -> item return to last slot
					last_pick_slot.put_into_slot(holding_item)
			holding_item = null
		
		# If not holding item -> pick item from that slot
		if Input.is_action_pressed("left_click"):
			if not holding_item and slot.item:
				last_pick_slot = slot
				selected_slot = slot
				if not is_instance_valid(slot.item):
					return
				holding_item = slot.item
				slot.pick_from_slot()
				holding_item.global_position = get_global_mouse_position()

func _input(_event: InputEvent) -> void:
	if holding_item:
		holding_item.global_position = get_global_mouse_position()

# Put item in the closest empty slot
func quickput_to_inventory(item: Item) -> void:
	var slot: InventorySlot
	for inv_slot: InventorySlot in $InventorySlot/SlotContainers.get_children():
		if inv_slot.item == null and not inv_slot.locked:
			slot = inv_slot
			break
	slot.put_into_slot(item)

func _on_btn_close_pressed() -> void:
	visible = false
	
	for slot: InventorySlot in $UpgradeBox/SlotContainer.get_children():
		if is_instance_valid(slot.item):
			var item = slot.item
			slot.pick_from_slot()
			quickput_to_inventory(item)
	
	get_item_stats()
	print(player_item_stat)

func get_item_stats():
	player_item_stat = {}
	for slot: InventorySlot in $EquipedItemSlot/SlotContainers.get_children():
		if not slot.item or slot.locked:
			continue
		var stats = slot.item.stat_values
		for stat in stats.keys():
				player_item_stat[stat] = player_item_stat.get(stat,0) + stats.get(stat)
