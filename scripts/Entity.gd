# An entity represents anything that placed i na level that has inherent
# behaviours, such as actors, obstacles, and floor tiles.
# Items are not entities: entities are what can use and store items.
extends Node2D
class_name Entity

var RogueLight = preload("res://scenes/RogueLight.tscn")

var tile = Vector2() # location within level
var emits_light = false # used for entities holding light sources
var light = false # stores light calculation node if emits_light is true
var title # generic title. #TODO: how to add detail?
var usable_inventory = false # flag for whether or not the inventory can be used
# all entities act as containers for items.
# entities do not contain other entities.
var inventory = {}
# reference to a UI element that is populated when looking through an inventory
var inventory_panel = false
# used when an entity needs to display another one on top
var target_alpha = 1
# flags for whether or not an entity is undergoing a tween
var in_color_tween = false
var in_motion_tween = false

# _ready just calls entity_ready, since _ready() cannot be overwritten
func _ready():
	# connect color and motion tweens
	$ColorTween.connect("tween_completed", self, "on_color_tween_completed")
	$MotionTween.connect("tween_completed", self, "on_motion_tween_completed")


# TODO: incomplete
func add_item(item_title):
	if !inventory.has(item_title):
		inventory[item_title] = {
			"count": 1,
			"item": Global.level.items[item_title]
		}
		if inventory_panel:
			inventory_panel.add_item_control(item_title)
	else:
		inventory[item_title].count += 1
		if inventory_panel:
			inventory_panel.update_item_control_count_by_title(item_title)


func remove_item(item_title):
	if inventory.has(item_title):
		inventory[item_title].count -= 1
		if inventory[item_title].count == 0:
			# remove item key when there's none of that item left
			inventory.erase(item_title)
			if inventory_panel:
				inventory_panel.remove_item_control(item_title)
		elif inventory_panel:
			inventory_panel.update_item_control_count_by_title(item_title)
	return false


func drop_item(item_title,equip_location=false):
	remove_item(item_title)
	var ground = Global.level.tilev(tile).ground
	ground.add_item(item_title)


func set_light():
	var light = RogueLight.instance()
	add_child(light)


func apply_motion_tween(target):
	in_motion_tween = true
	$MotionTween.interpolate_property(
		self, "position", position, target, Global.TWEEN_DURATION,
		Tween.TRANS_QUAD, Tween.EASE_OUT
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
