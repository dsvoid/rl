extends Tween


func _ready():
	pass

func tint_tile(sprite, target_color):
	interpolate_property(sprite, "modulate", sprite.get_modulate(), target_color, 0.0833, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	start()
