# An entity represents anything that is placed within a level.
# It is the base class for obstacles, actors, items, and floor tiles.
extends Node2D
class_name Entity

var RogueLight = preload("res://scenes/RogueLight.tscn")

var tile = Vector2() # location within level
var emits_light = false # used for items like torches, or actors holding them
var light = false # stores light calculation node if emits_light is true
var title # generic title for objects. #TODO: how to add detail?
var usable_inventory = false # flag for whether or not the inventory can be used
# all entities act as containers for items.
# entities do not contain other entities.
var inventory = {}
# a pre-sorted list of item titles in the current inventory.
# used to quickly display inventory alphabetically without sorting constantly.
var inventory_sorted_by_title = []
# reference to a panel that can be created when looking through an inventory
var inventory_panel = false

var target_alpha = 1 # used when an entity needs to display another one on top
# flags for whether or not an entity is undergoing a tween
var in_color_tween = false
var in_motion_tween = false

# _ready just calls entity_ready, since _ready() cannot be overwritten
func _ready():
	# connect color and motion tweens
	$ColorTween.connect("tween_completed", self, "on_color_tween_completed")
	$MotionTween.connect("tween_completed", self, "on_motion_tween_completed")


# TODO: incomplete
func add_item(item):
	if !inventory.has(item.title):
		inventory[item.title] = [item]
		# add inventory item name to alphabetically sorted list of items
		var insertion_index = inventory_sorted_by_title.bsearch(item.title)
		inventory_sorted_by_title.insert(insertion_index, item.title)
		if inventory_panel:
			inventory_panel.add_inventory_label(item.title, insertion_index)
	else:
		inventory[item.title].append(item)
		if inventory_panel:
			inventory_panel.update_item_count(item.title)
	


func remove_item(item_title):
	if inventory.has(item_title):
		var item = inventory[item_title].pop_front()
		if inventory[item_title].size() == 0:
			# remove item key when there's none of that item left
			inventory.erase(item_title)
			var removal_index = inventory_sorted_by_title.bsearch(item_title)
			inventory_sorted_by_title.remove(removal_index)
			if inventory_panel:
				inventory_panel.remove_inventory_label(removal_index)
		return item
	return false


func item_count(item_title):
	if !inventory.has(item_title):
		return 0
	return inventory[item_title].size()


# call this after running remove_item. This only destroys the item.
func destroy_item(item):
	item.queue_free()


func set_light():
	var light = RogueLight.instance()
	add_child(light)


func apply_motion_tween(target):
	in_motion_tween = true
	$MotionTween.interpolate_property(
		self, "position", position, target, Global.TWEEN_DURATION,
		Tween.TRANS_LINEAR
	)
	$MotionTween.start()


func on_motion_tween_completed(object, key):
	in_motion_tween = false


func apply_color_tween(target):
	in_color_tween = true
	target = Color(target.r, target.g, target.b, target_alpha)
	$ColorTween.interpolate_property(
		$Sprite, "modulate", $Sprite.modulate, target, Global.TWEEN_DURATION,
		Tween.TRANS_LINEAR
	)
	$ColorTween.start()


func fade(alpha):
	target_alpha = alpha
	in_color_tween = true
	var rgb = $Sprite.modulate
	var target = Color(rgb.r, rgb.g, rgb.b, target_alpha)
	$ColorTween.interpolate_property(
		$Sprite, "modulate", $Sprite.modulate, target, Global.TWEEN_DURATION,
		Tween.TRANS_LINEAR
	)
	$ColorTween.start()


func on_color_tween_completed(object, key):
	in_color_tween = false
