extends Node

const TILE_WIDTH = 12
const TILE_HEIGHT = 12
const BASE_VIEWPORT_WIDTH = 640
const BASE_VIEWPORT_HEIGHT = 360
const TWEEN_DURATION = float(1)/6
const INPUT_COOLDOWN = float(1)/6
var scale
var relative_tile_size

func set_scale():
	scale = int(OS.window_size.y)/360
	relative_tile_size = Vector2(scale*TILE_WIDTH, scale*TILE_HEIGHT)

func mouse_position():
	var mp = get_node("/root").get_mouse_position()
	mp = Vector2(floor(mp.x),floor(mp.y))
	return mp
