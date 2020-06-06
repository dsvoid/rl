# An entity represents anything that is placed within a level.
# It is the base class for obstacles, actors, items, and floor tiles.
extends Node2D
class_name Entity

var tile = Vector2() # location within level
var emits_light = false # used for items like torches, or actors holding them
var inventory = {} # any entity can act as a container for other entities
var has_inventory = false # flag for whether or not the inventory can be used
# flags for whether or not an entity is undergoing a tween
var in_color_tween = false
var in_motion_tween = false


func _ready():
	# connect color and motion tweens
	$ColorTween.connect("tween_completed", self, "on_color_tween_completed")
	$MotionTween.connect("tween_completed", self, "on_motion_tween_completed")

func apply_motion_tween(target):
	in_motion_tween = true
	$MotionTween.interpolate_property(
		self, "position", position, target, 0.0833,
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	$MotionTween.start()


func on_motion_tween_completed(object, key):
	in_motion_tween = false


func apply_color_tween(target):
	in_color_tween = true
	$ColorTween.interpolate_property(
		$Sprite, "modulate", $Sprite.modulate, target, 0.0833, Tween.TRANS_LINEAR
	)
	$ColorTween.start()


func on_color_tween_completed(object, key):
	in_color_tween = false
