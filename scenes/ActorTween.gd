extends Tween


func _ready():
	pass


func move_actor(actor, target):
	interpolate_property(actor, "position", actor.get_position(), target, 0.0833, Tween.TRANS_QUART, Tween.EASE_OUT)
	start()


#func _process(delta):
#    pass
