extends Actor
class_name Player

var current_input_time = Global.INPUT_COOLDOWN


func _process(delta):
	# do not process certain inputs until some time has passed
	# TODO: move to InputHandler?
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
		var new_tile = Global.level.tilev(target)
		if !movement_collision(new_tile):
			move(direction)
		current_input_time = 0

func movement_collision(target_tile):
	if !target_tile || target_tile.actor || target_tile.obstacle:
		return true
	return false

