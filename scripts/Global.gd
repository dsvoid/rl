extends Node

const TILE_WIDTH = 12
const TILE_HEIGHT = 12
const BASE_VIEWPORT_WIDTH = 640
const BASE_VIEWPORT_HEIGHT = 360
const TWEEN_DURATION = float(1)/5
const INPUT_COOLDOWN = float(1)/5
var scale
var relative_tile_size
var level
var input_handler
var inventory_hover_stylebox = load("res://themes and styles/stylebox_hov.tres")
# TODO: assess if useful
var inventory_blank_stylebox = load("res://themes and styles/stylebox_rl.tres")


func set_scale():
	scale = int(OS.window_size.y)/360
	relative_tile_size = Vector2(scale*TILE_WIDTH, scale*TILE_HEIGHT)
