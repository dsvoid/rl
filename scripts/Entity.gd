# An entity represents anything that is placed within a level.
# It is the base class for obstacles, actors, items, and floor tiles.
extends Node2D
class_name Entity

var RogueLight = preload("res://scenes/RogueLight.tscn")

var tile = Vector2() # location within level
var emits_light = false # used for items like torches, or actors holding them
var light = false # stores light calculation node if emits_light is true
var usable_inventory = false # flag for whether or not the inventory can be used
var inventory = [] # any entity can act as a container for other entities
var target_alpha = 1 # used when an entity needs to display another one on top
# flags for whether or not an entity is undergoing a tween
var in_color_tween = false
var in_motion_tween = false


func _ready():
	# connect color and motion tweens
	$ColorTween.connect("tween_completed", self, "on_color_tween_completed")
	$MotionTween.connect("tween_completed", self, "on_motion_tween_completed")


func add_item(item):
	inventory.append(item)


func set_light():
	var light = RogueLight.instance()
	add_child(light)


func apply_motion_tween(target):
	in_motion_tween = true
	$MotionTween.interpolate_property(
		self, "position", position, target, Global.TWEEN_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_OUT
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
