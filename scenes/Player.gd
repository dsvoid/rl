extends Actor
class_name Player


export var input_cooldown = 0.1667
var current_input_time = input_cooldown
var tween


func _ready():
	$ActorSprite.set_texture(load("res://assets/sprites/player.png"))


func _process(delta):
	# do not process certain inputs until some time has passed
	if current_input_time < input_cooldown:
		current_input_time += delta
		return
	# do not process certain inputs if still moving
	if is_moving:
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
		var target_tile = get_parent().tilev(target)
		if target_tile && !target_tile.actor && !target_tile.obstacle:
			# change tile position
			get_parent().tilev(tile).actor = false
			tile.x = target.x
			tile.y = target.y
			get_parent().tilev(tile).actor = self
			$Vision.compute_fov()
			get_parent().get_node("VisionRenderer").apply_vision($Vision.old_visible_tiles, $Vision.visible_tiles)
			# modify position on screen
			is_moving = true
			var target_position = Vector2()
			target_position.x = position.x + TILE_WIDTH * direction.x
			target_position.y = position.y + TILE_HEIGHT * direction.y
			$ActorTween.move_actor(self, target_position)
		current_input_time = 0

