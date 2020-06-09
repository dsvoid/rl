extends Actor
class_name Player

var current_input_time = Global.INPUT_COOLDOWN
var mouse_tile

func _process(delta):
	# locate the tile the mouse is hovering over
	# TODO: move location of this logic
	var valid_mouse_context = false
	if !in_motion_tween:
		var label = get_node("/root/Main/DebugLabel")
		mouse_tile = get_mouse_tile()
		# highlight tile being hovered over
		if get_parent().in_boundsv(mouse_tile) && $Vision.visible_tiles.has(mouse_tile):
			get_node("../Renderer").mouse_highlight(mouse_tile)
			valid_mouse_context = true
#			label.text = "%s" % mouse_tile
		else:
#			label.text = "%s The Quick Brown Fox Jumps Over The Lazy Dog" % mouse_tile
			get_node("../Renderer").hide_mouse_highlight()
	
	# do not process certain inputs until some time has passed
	if current_input_time < Global.INPUT_COOLDOWN:
		current_input_time += delta
		return
	
	# do not process certain inputs if still moving
	if in_motion_tween:
		return
	
	if valid_mouse_context:
		process_mouse_input()
	
	var direction = Vector2()
	if Input.is_action_pressed("actor_up"):
		direction.x = 0
		direction.y = -1
	if Input.is_action_pressed("actor_down"):
		direction.x = 0
		direction.y = 1
	if Input.is_action_pressed("actor_left"):
		direction.x = -1
		direction.y = 0
	if Input.is_action_pressed("actor_right"):
		direction.x = 1
		direction.y = 0
	
	if direction.x != 0 || direction.y != 0:
		# check for any collisions before moving
		var target = Vector2(tile.x+direction.x, tile.y+direction.y)
		var new_tile = get_parent().tilev(target)
		if !movement_collision(new_tile):
			var old_tile = get_parent().tilev(tile)
			# apply an alpha tween on sprites the player moves between
			old_tile.ground.fade(1)
			new_tile.ground.fade(0)
			if old_tile.obstacle:
				old_tile.obstacle.fade(1)
			if new_tile.obstacle:
				new_tile.obstacle.fade(0)
			# change tile position
			get_parent().tilev(tile).actor = false
			tile.x = target.x
			tile.y = target.y
			get_parent().tilev(tile).actor = self
			# recompute FOV from new position
			$Vision.compute_fov()
			get_parent().get_node("Renderer").apply_vision($Vision)
			# modify position on screen
			var target_position = Vector2()
			target_position.x = position.x + Global.TILE_WIDTH * direction.x
			target_position.y = position.y + Global.TILE_HEIGHT * direction.y
			apply_motion_tween(target_position)
			get_node("../Renderer").hide_mouse_highlight()
			get_node("/root/Main/ContextMenu").hide_context_menu()
		current_input_time = 0


func movement_collision(target_tile):
	if !target_tile || target_tile.actor || target_tile.obstacle:
		return true
	return false

# TODO: maybe refactor to a different place
func get_mouse_tile():
	var mouse_position = Global.mouse_position()
	var viewport_position = get_node("/root/Main/ViewportContainer").rect_position
	mouse_position = mouse_position - viewport_position
	var mouse_tile = Vector2(
		int(mouse_position.x/Global.TILE_WIDTH),
		int(mouse_position.y/Global.TILE_HEIGHT)
	)
	# TODO: get rid of magic numbers
	var w = get_parent().width
	var h = get_parent().height
	if tile.x > 14:
		if tile.x < w-14:
			mouse_tile.x += tile.x-14
		else:
			mouse_tile.x += w-29
	if tile.y > 14:
		if tile.y < h-14:
			mouse_tile.y += tile.y-14
		else:
			mouse_tile.y += h-29
	return mouse_tile

func process_mouse_input():
	var mouse_position = Global.mouse_position()
	var context_menu = get_node("/root/Main/ContextMenu")
	if Input.is_action_just_pressed("left_click"):
		if context_menu.visible:
			context_menu.hide_context_menu()
		# TODO: print the rendered tile name
		
		# TODO: log some flavour text about the tile
		pass
	elif Input.is_action_just_pressed("right_click"):
		context_menu.show_context_menu(mouse_tile)
		pass
