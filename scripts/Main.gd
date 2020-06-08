extends Node2D

var vpc
var vpc_tween
var base_vpc_position
var menu
var menu_tween

func _ready():
	vpc = $ViewportContainer
	vpc_tween = $ViewportContainer/ViewportTween
	base_vpc_position = vpc.rect_position
	menu = $MenuPanel
	menu_tween = $MenuPanel/MenuTween
	Global.set_scale()


func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		Global.set_scale()
	
	if Input.is_action_just_pressed("toggle_menu"):
		if vpc.rect_position != base_vpc_position:
			hide_menu()
		else:
			show_menu()


func show_menu():
	vpc_tween.interpolate_property(
		vpc, "rect_position", vpc.rect_position, Vector2(0,0),
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	vpc_tween.start()
	menu_tween.interpolate_property(
		menu, "rect_position", menu.rect_position, Vector2(348,0),
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	menu_tween.start()


func hide_menu():
	vpc_tween.interpolate_property(
		vpc, "rect_position", vpc.rect_position, base_vpc_position,
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	vpc_tween.start()
	menu_tween.interpolate_property(
		menu, "rect_position", menu.rect_position, Vector2(640,0),
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	menu_tween.start()
