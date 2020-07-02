extends Actor
class_name Player

var current_input_time = Global.INPUT_COOLDOWN
var valid_mouse_tile_context


func _ready():
	inventory_panel = get_node("/root/Main/MenuPanel/InventoryPanel")
	inventory_panel.init_display(self)

func _process(delta):
	# locate the tile the mouse is hovering over
	# TODO: move location of this logic
	var mt = InputHandler.mouse_tile()
	if in_motion_tween:
		valid_mouse_tile_context = false
		Global.level.get_node("Renderer").hide_mouse_highlight()
	if !in_motion_tween && InputHandler.mouse_position_changed():
		var label = get_node("/root/Main/DebugLabel")
		# highlight tile being hovered over
		if (Global.level.in_boundsv(mt) 
		&& $Vision.visible_tiles.has(mt)):
			valid_mouse_tile_context = true
			Global.level.get_node("Renderer").mouse_highlight(mt)
#			label.text = "%s" % mt
		else:
			valid_mouse_tile_context = false
			Global.level.get_node("Renderer").hide_mouse_highlight()
	
	# do not process certain inputs until some time has passed
	# TODO: move to InputHandler?
	if current_input_time < Global.INPUT_COOLDOWN:
		current_input_time += delta
		return
	
	# do not process certain inputs if still moving
	if in_motion_tween:
		return
	
	if valid_mouse_tile_context:
		InputHandler.process_mouse_tile_input()
	
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
		var new_tile = Global.level.tilev(target)
		if !movement_collision(new_tile):
			var old_tile = Global.level.tilev(tile)
			# apply an alpha tween on sprites the player moves between
			old_tile.ground.fade(1)
			new_tile.ground.fade(0)
			if old_tile.obstacle:
				old_tile.obstacle.fade(1)
			if new_tile.obstacle:
				new_tile.obstacle.fade(0)
			# change tile position
			Global.level.tilev(tile).actor = false
			tile.x = target.x
			tile.y = target.y
			Global.level.tilev(tile).actor = self
			# recompute FOV from new position
			$Vision.compute_fov()
			Global.level.get_node("Renderer").apply_vision($Vision)
			# modify position on screen
			var target_position = Vector2()
			target_position.x = position.x + Global.TILE_WIDTH * direction.x
			target_position.y = position.y + Global.TILE_HEIGHT * direction.y
			apply_motion_tween(target_position)
			Global.level.get_node("Renderer").hide_mouse_highlight()
#			get_node("/root/Main/ContextMenu").hide_context_menu()
		current_input_time = 0


func movement_collision(target_tile):
	if !target_tile || target_tile.actor || target_tile.obstacle:
		return true
	return false

