extends Actor
class_name Player

var current_input_time = Global.INPUT_COOLDOWN


func _process(delta):
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
			get_parent().get_node("Renderer").apply_vision(
				$Vision.old_visible_tiles,
				$Vision.visible_tiles
			)
			# modify position on screen
			var target_position = Vector2()
			target_position.x = position.x + Global.TILE_WIDTH * direction.x
			target_position.y = position.y + Global.TILE_HEIGHT * direction.y
			apply_motion_tween(target_position)
		current_input_time = 0


func movement_collision(target_tile):
	if !target_tile || target_tile.actor || (target_tile.obstacle && target_tile.obstacle.blocks_movement):
		return true
	return false
