extends Panel

func _ready():
	visible = false

func show_context_menu(location):
	var mouse_position = Global.mouse_position()
	rect_position = mouse_position
	var level = get_node("/root/Main/ViewportContainer/Viewport/Level")
	var tile = level.tilev(location)
	if tile.obstacle:
		$NameLabel.text = tile.obstacle.title
	elif tile.actor:
		$NameLabel.text = tile.actor.title
	elif tile.ground:
		var title = false
		var render_index = tile.ground.render_index
		if render_index > -1:
			title = tile.ground.inventory[render_index].title
		elif tile.ground.title:
			title = tile.ground.title
		if title:
			$NameLabel.text = title
		else:
			$NameLabel.text = ""
	if $NameLabel.text != "":
		visible = true
		rect_size = $NameLabel.get_minimum_size()
		rect_size.x += 2
		rect_size.y = 12
		# draw rest of context
	else:
		visible = false
		# draw rest of context

func hide_context_menu():
	visible = false
