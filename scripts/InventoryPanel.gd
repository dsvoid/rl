#FFFFFF  U     U   CCCCC   K     K  !
#        U     U  C     C  K    K   !
#FFF     U     U  C        KKKKK    !
#        U     U  C     C  K    K
#         UUUUU    CCCCC   K     K  !

extends Panel

var ItemControl = preload("res://scenes/ItemControl.tscn")
var entity
var controls = []
var equipped_control_indices = {}


func init_display(init_entity):
	entity = init_entity
	# actors with equipped items affect the number of inventory items to draw
	for item_title in entity.inventory.keys():
		add_item_control(entity.inventory.item_title)
	if entity.get("hands"):
		if entity.hands.left:
			add_item_control(entity.hands.left, "left")
		if entity.hands.right:
			add_item_control(entity.hands.right, "right")
		if entity.hands.both:
			add_item_control(entity.hands.both, "both")


func add_item_control(item_title, equip_location=false):
	var new_control = ItemControl.instance()
	new_control.item_title = item_title
	new_control.get_node("ItemLabel").text = item_title
	new_control.equip_location = equip_location
	add_child(new_control)
	var index = controls.bsearch_custom(item_title,self,"ip_bsearch")
	controls.insert(index,new_control)
	if equip_location:
		new_control.get_node("EquipSprite").region_rect = Rect2(12,0,12,12)
		equipped_control_indices[equip_location] = index
	else:
		update_item_control_count(new_control)
	new_control.rect_position.y = index * Global.TILE_HEIGHT
	for i in range(index+1,controls.size()):
		controls[i].rect_position.y += Global.TILE_HEIGHT


func remove_item_control(item_title,equip_location=false):
	var index
	if equip_location:
		index = equipped_control_indices[equip_location]
	else:
		index = controls.bsearch_custom(item_title,self,"ip_bsearch")
		for hand in entity.hands.keys():
			equipped_control_indices
	if index == controls.size():
		index = controls.size()-1
	var item_control = controls[index]
	controls.remove(index)
	item_control.queue_free()
	for i in range(index,controls.size()):
		controls[i].rect_position.y -= Global.TILE_HEIGHT


func update_item_control_count(control):
	control.get_node("ItemLabel").text = control.item_title
	var count = entity.inventory[control.item_title].count
	if count > 1:
		control.get_node("ItemLabel").text += " (%s)" % count
	pass


func update_item_control_count_by_title(item_title):
	var index = controls.bsearch_custom(item_title,self,"ip_bsearch")
	while controls[index].equip_location:
		index += 1
	var control = controls[index]
	update_item_control_count(control)


func ip_bsearch(a,b):
	if typeof(a) != 4:
		a = a.item_title
	if typeof(b) != 4:
		b = b.item_title
	if a < b:
		return true
	return false
