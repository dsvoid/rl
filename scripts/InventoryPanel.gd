extends Panel

var InventoryLabel = preload("res://scenes/InventoryLabel.tscn")
var labels = {}
var visible_labels # TODO: implement filtering later and use this list for it
var entity

func init_inventory_display(input_entity):
	entity = input_entity
	for i in range(entity.inventory_sorted_by_title.size()):
		add_inventory_label(entity.inventory_sorted_by_title[i],i)

# function assumes item exists in inventory
func update_item_count(item_title):
	labels[item_title].text = item_title
	var item_count = entity.item_count(item_title)
	if item_count > 1:
		labels[item_title].text += " (%s)" % item_count
	return true

func add_inventory_label(item_title, insertion_index):
	var new_label = InventoryLabel.instance()
	add_child(new_label)
	labels[item_title] = new_label
	update_item_count(item_title)
	print("=== inentory size is currently %s" % entity.inventory_sorted_by_title.size())
	print(range(insertion_index, entity.inventory_sorted_by_title.size()))
	for i in range(insertion_index, entity.inventory_sorted_by_title.size()):
		print("updating label position for index %s" % i)
		var update_position_title = entity.inventory_sorted_by_title[i]
		labels[update_position_title].rect_position.y = Global.TILE_HEIGHT * i

func remove_inventory_label(removal_index):
	labels.remove(removal_index)
	for i in range(removal_index, entity.inventory_sorted_by_title.size()):
		var update_position_title = entity.inventory_sorted_by_title[i]
		labels[update_position_title].rect_position.y = Global.TILE_HEIGHT * i
