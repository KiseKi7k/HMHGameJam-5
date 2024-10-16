class_name ItemInfoDisplay
extends NinePatchRect

var current_item: Item = null

func _ready() -> void:
	display_item(null)
	%BtnDiscard.disabled = true

func display_item(item: Item) -> void:
	if item:
		current_item = item
		%ItemTexture.texture = item.item_resource.item_texture
		%ItemNameLabel.text = item.item_resource.item_name
		if item.tier > 0:
			%TierLabel.text = "+%s" %str(item.tier)
		else: %TierLabel.text = ""
		display_stats(item.stat_values)
		%BtnDiscard.disabled = false
	else:
		%ItemTexture.texture = null
		%ItemNameLabel.text = ""
		%TierLabel.text = ""
		for label in %StatLabelContainer.get_children():
			label.queue_free()

func display_stats(stat_values: Dictionary) -> void:
	for label in %StatLabelContainer.get_children(): # Clear old label
		label.queue_free()
		
	for stat in stat_values.keys(): # Create new label
		var value = stat_values.get(stat) as float
		
		var label = Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		if stat in ["Defence", "Piece", "Health Regen"]:
			label.text = "%s +%s"  %[stat, str(value)]
		else: label.text = "%s +%s%%"  %[stat, str(value)]
		%StatLabelContainer.add_child(label)


func _on_btn_discard_pressed() -> void:
	current_item.queue_free()
	display_item(null)
	%BtnDiscard.disabled = true
