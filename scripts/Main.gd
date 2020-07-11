extends Node2D

var vpc
var vpc_tween
var base_vpc_position
var menu
var menu_tween
var base_menu_position
var transfer_menu
var transfer_menu_tween
var base_transfer_menu_position


func _ready():
	vpc = $ViewportContainer
	vpc_tween = $ViewportContainer/ViewportTween
	base_vpc_position = vpc.rect_position
	menu = $MenuPanel
	menu_tween = $MenuPanel/MenuTween
	base_menu_position = menu.rect_position
	transfer_menu = $TransferMenu
	transfer_menu_tween = $TransferMenu/TransferMenuTween
	base_transfer_menu_position = transfer_menu.rect_position
	Global.set_scale()


func _process(delta):
	# TODO: move to separate input handler node
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		Global.set_scale()
	
	if Input.is_action_just_pressed("toggle_menu"):
		if menu.rect_position != base_menu_position:
			center_viewport()
			hide_transfer_menu()
			hide_menu()
		else:
			left_viewport()
			hide_transfer_menu()
			show_menu()


func center_viewport():
	vpc_tween.interpolate_property(
		vpc, "rect_position", vpc.rect_position, base_vpc_position,
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	vpc_tween.start()


func left_viewport():
	vpc_tween.interpolate_property(
		vpc, "rect_position", vpc.rect_position, Vector2(0,0),
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	vpc_tween.start()


func show_menu():
	menu_tween.interpolate_property(
		menu, "rect_position", menu.rect_position, Vector2(348,0),
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	menu_tween.start()


func hide_menu():
	menu_tween.interpolate_property(
		menu, "rect_position", menu.rect_position, base_menu_position,
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	menu_tween.start()


func show_transfer_menu():
	transfer_menu_tween.interpolate_property(
		transfer_menu, "rect_position", transfer_menu.rect_position, Vector2(348,0),
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	transfer_menu_tween.start()


func hide_transfer_menu():
	transfer_menu_tween.interpolate_property(
		transfer_menu, "rect_position", transfer_menu.rect_position, base_transfer_menu_position,
		Global.TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	transfer_menu_tween.start()


func is_transfer_menu_open():
	return transfer_menu.rect_position != base_transfer_menu_position
