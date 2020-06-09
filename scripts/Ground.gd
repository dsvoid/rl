extends Entity
class_name Ground

# Grounds are entities because they need to be able to store items in their own
# inventory as a pile of stuff. They also have sprite representations.

var render_index = -1 # stores the index of the current rendered sprite
var render_sprite # stores which sprite is passed to the renderer


func _ready():
	render_sprite = $Sprite


func add_item(item):
	.add_item(item)
	# TODO: item prioritization on visibility.
	render_sprite.visible = false
	render_sprite = item.get_node("Sprite")
	render_index = inventory.size() - 1
	render_sprite.visible = true


# custom color tween code due to the way ground displays sprite
func apply_color_tween(target):
	in_color_tween = true
	target = Color(target.r, target.g, target.b, target_alpha)
	$ColorTween.interpolate_property(
		render_sprite, "modulate", render_sprite.modulate, target,
		Global.TWEEN_DURATION, Tween.TRANS_LINEAR
	)
	$ColorTween.start()


func fade(alpha):
	target_alpha = alpha
	in_color_tween = true
	var rgb = render_sprite.modulate
	var target = Color(rgb.r, rgb.g, rgb.b, target_alpha)
	$ColorTween.interpolate_property(
		render_sprite, "modulate", render_sprite.modulate, target, Global.TWEEN_DURATION,
		Tween.TRANS_LINEAR
	)
	$ColorTween.start()
