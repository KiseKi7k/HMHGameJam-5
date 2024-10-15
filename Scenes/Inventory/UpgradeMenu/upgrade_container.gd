class_name UpgradeContainer
extends NinePatchRect

@onready var btn_select: Button = %BtnSelect
var item: Item:
	set(value):
		item = value
		display_item(value)

func display_item(item: Item) -> void:
	%ItemTexture.texture = item.item_resource.item_texture
	%ItemNameLabel.text = item.item_resource.item_name
	display_stats(item.stat_values)
		
func display_stats(stat_values: Dictionary) -> void:
	for label in %StatLabelContainer.get_children(): # Clear old label
		label.queue_free()
		
	for stat in stat_values.keys(): # Create new label
		var value = stat_values.get(stat) as float
		
		var label = Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		label.text = "%s +%s" %[stat, str(value)]
		%StatLabelContainer.add_child(label)
	
