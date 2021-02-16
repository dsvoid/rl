extends Node

const TILE_WIDTH = 12
const TILE_HEIGHT = 12
const BASE_VIEWPORT_WIDTH = 348
const BASE_VIEWPORT_HEIGHT = 348
const TWEEN_DURATION = float(1)/5
const INPUT_COOLDOWN = float(1)/5
var scale
var relative_tile_size
var level
var input_handler
var action_queue


func set_scale():
	scale = int(OS.window_size.y)/360
	relative_tile_size = Vector2(scale*TILE_WIDTH, scale*TILE_HEIGHT)
