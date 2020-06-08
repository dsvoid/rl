extends Actor
class_name Player

var current_input_time = Global.INPUT_COOLDOWN


func _process(delta):
	# draw a highlight when mouse is over a visible tile
	var mouse_position = get_viewport().get_mouse_position()
	var mouse_position_scaled = Vector2(mouse_position.x, mouse_position.y)
	var viewport_position = get_node("/root/Main/ViewportContainer").rect_position
	mouse_position_scaled.x -= (viewport_position.x*(Global.scale-1))
	mouse_position_scaled.y -= (viewport_position.y*(Global.scale-1))
	mouse_position_scaled.x = int(mouse_position_scaled.x)/3
	mouse_position_scaled.y = int(mouse_position_scaled.y)/3
	var cam = get_node("/root/Main/ViewportContainer/Viewport/Camera2D")
	var cam_position = Vector2(floor(cam.position.x)-6, floor(cam.position.y)-6)
	var corner_position = Vector2(max(cam_position.x-168,0), max(cam_position.y-168,0))
	var selected_tile = Vector2(
		int(corner_position.x+mouse_position_scaled.x)/Global.TILE_WIDTH,
		int(corner_position.y+mouse_position_scaled.y)/Global.TILE_HEIGHT
	)
	var label = get_node("/root/Main/Label")
	label.text = "%s" % (selected_tile)
	# do not process certain inputs until some time has passed
	if current_input_time < Global.INPUT_COOLDOWN:
		current_input_time += delta
		return
	
	# do not process certain inputs if still moving
	if in_motion_tween:
		return
	
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
		current_input_time = 0


func movement_collision(target_tile):
	if !target_tile || target_tile.actor || target_tile.obstacle:
		return true
	return false
