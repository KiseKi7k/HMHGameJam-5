class_name ItemResource
extends Resource

@export var item_name: String
@export var item_id: int
@export var item_stat: Dictionary [String, float]
@export var item_texture: Texture2D

static var item_resoruces_list: Dictionary[int, ItemResource]

static func load_resource():
	var dir_path = "res://Scenes/Inventory/ItemResource/"
	var dir = DirAccess.open(dir_path)
	for file in dir.get_files():
		if file.ends_with('.tres'):
			var resource_file_path = dir_path + '/' + file
			var item_resource: ItemResource = load(resource_file_path)
			item_resoruces_list[item_resource.item_id] = item_resource
		else: continue
	
