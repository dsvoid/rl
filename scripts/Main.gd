extends Node2D

var vpc


func _ready():
	vpc = $ViewportContainer
	Global.set_scale()


func _process(delta):
	# TODO: move to separate input handler node
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		Global.set_scale()
