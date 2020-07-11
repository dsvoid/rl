extends Panel

var ItemControl = preload("res://scenes/ItemControl.tscn")
var entity
var controls = []
var active_item_control = false


func init_display(init_entity):
	if init_entity == entity:
		return
	clear_display()
	entity = init_entity
	for i in entity.inventory:
		add_item_control(i)
	if entity.get("hands"):
		for i in entity.hands:
			if entity.hands[i]:
				add_item_control(entity.hands[i],i)


func clear_display():
	if controls.size() > 0:
		for i in range(controls.size()-1,-1,-1):
			var control = controls[i]
			controls.remove(i)
			controls[i].queue_free()


func add_item_control(item_title, equip_location="none"):
	var new_control = ItemControl.instance()
	new_control.item_title = item_title
	new_control.equip_location = equip_location
	add_child(new_control)
	var index = controls.bsearch_custom(item_title,self,"ip_bsearch")
	if controls.size() > 0 && index < controls.size() && new_control.equip_location == "none":
		# get the existing "com"parison control that is checked before the insertion
		var com_control = controls[index]
		while com_control.equip_location != "none" && com_control.item_title == item_title:
			index += 1
			if index != controls.size():
				com_control = controls[index]
			else:
				break
	controls.insert(index,new_control)
	if equip_location != "none":
		add_equip_icon(new_control,equip_location)
		new_control.get_node("ItemLabel").text = item_title
	else:
		update_item_control_count(new_control)
	# TODO: fix whatever forces me to reduce the rect_position.y by TILE_HEIGHT
	new_control.rect_position.y = (index * Global.TILE_HEIGHT) - Global.TILE_HEIGHT + 1
	new_control.rect_position.x = 1
	for i in range(index, controls.size()):
		controls[i].rect_position.y += Global.TILE_HEIGHT


func remove_item_control(item_title,equip_location="none"):
	var index = controls.bsearch_custom(item_title,self,"ip_bsearch")
	var control = controls[index]
	while control.equip_location != equip_location:
		index += 1
		control = controls[index]
	controls.remove(index)
	control.queue_free()
	for i in range(index, controls.size()):
		controls[i].rect_position.y -= Global.TILE_HEIGHT


func update_item_control_count(control):
	var item_title = control.item_title
	var item_label = control.get_node("ItemLabel")
	item_label.text = item_title
	var count = entity.inventory[item_title].count
	if count > 1:
		item_label.text += " (%s)" % count


func update_item_control_count_by_title(item_title):
	var index = controls.bsearch_custom(item_title,self,"ip_bsearch")
	var control = controls[index]
	while control.equip_location != "none":
		index += 1
		control = controls[index]
	var item_label = control.get_node("ItemLabel")
	item_label.text = item_title
	var count = entity.inventory[item_title].count
	if count > 1:
		item_label.text += " (%s)" % count


func ip_bsearch(a,b):
	if typeof(a) != 4:
		a = a.item_title
	if typeof(b) != 4:
		b = b.item_title
	if a < b:
		return true
	return false


func add_equip_icon(control,equip_location):
	var equip_sprite = control.get_node("EquipSprite")
	if equip_location == "left":
		equip_sprite.region_rect = Rect2(24,0,12,12)
	if equip_location == "right":
		equip_sprite.region_rect = Rect2(36,0,12,12)
	if equip_location == "both":
		equip_sprite.region_rect = Rect2(48,0,12,12)
