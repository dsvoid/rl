extends Node

var mouse_position = Vector2(-1,-1)
var previous_mouse_position
var mouse_tile
# variables to determine is a click is a double click or not
var last_left_click_time = 0
var last_left_click_tile = Vector2(-1,-1)
# default length of a double click is 500ms according to msoft
const double_click_time = 0.5
var inventory_panel
var transfer_panel_player
var transfer_panel_other
var active_transfer_panel = false


func _ready():
	Global.input_handler = self
	inventory_panel = get_node("/root/Main/MenuPanel/InventoryPanel")
	transfer_panel_player = get_node("/root/Main/TransferMenu/TransferPanelPlayer")
	transfer_panel_other = get_node("/root/Main/TransferMenu/TransferPanelOther")


func _process(delta):
	last_left_click_time += delta
	if is_instance_valid(inventory_panel.active_item_control):
		active_transfer_panel = false
		process_item_control_input()
	elif is_instance_valid(transfer_panel_player.active_item_control):
		active_transfer_panel = "player"
		process_transfer_control_input()
	elif is_instance_valid(transfer_panel_other.active_item_control):
		active_transfer_panel = "other"
		process_transfer_control_input()


func mouse_position():
	var mp = get_node("/root").get_mouse_position()
	previous_mouse_position = mouse_position
	mouse_position = Vector2(floor(mp.x),floor(mp.y))
	return mouse_position


func mouse_position_changed():
	return previous_mouse_position != mouse_position


# sets the tile the mouse is hovering over
# only run this function if there's a player on the level
func mouse_tile():
	mouse_position()
	var viewport_position = get_node("/root/Main/ViewportContainer").rect_position
	var mouse_position_relative = mouse_position - viewport_position
	var mt = Vector2(
		int(mouse_position_relative.x/Global.TILE_WIDTH),
		int(mouse_position_relative.y/Global.TILE_HEIGHT)
	)
	# TODO: get rid of magic numbers
	var w = Global.level.width
	var h = Global.level.height
	var tile = Global.level.p.tile
	if tile.x > 14:
		if tile.x < w-14:
			mt.x += tile.x-14
		else:
			mt.x += w-29
	if tile.y > 14:
		if tile.y < h-14:
			mt.y += tile.y-14
		else:
			mt.y += h-29
	mouse_tile = mt
	return mouse_tile


# executed from player process function
# when the mouse is hovering over a valid tile for player actions
func process_mouse_tile_input():
	if Input.is_action_just_pressed("left_click"):
		if (last_left_click_time <= double_click_time
		&& last_left_click_tile == mouse_tile):
			# register double click
			double_click_action()
		else:
			# register single click
			# single_click_action()?
			pass
		last_left_click_time = 0
		last_left_click_tile = mouse_tile
		pass
	elif Input.is_action_just_pressed("right_click"):
		pass
#		get_node("/root/Main/ContextMenu").show_context_menu(mouse_tile)


func double_click_action():
	var player_tile = Global.level.p.tile
	var level_tile = Global.level.tilev(mouse_tile)
	if player_tile == mouse_tile:
		# not sure what to do if you double click yourself
		return
	if !neighbouring_tiles(player_tile,mouse_tile):
		# not sure what should happen if double-clickin a non-neighbour tile
		return
	var obstacle = level_tile.obstacle
	if obstacle:
		if obstacle.usable_inventory:
			# open obstacle's inventory
			# assign obstacle's inventory to the loot panel's ItemList
			# display the loot panel
			obstacle.inventory_panel = transfer_panel_other
			transfer_panel_other.init_display(obstacle)
			get_node("/root/Main").left_viewport()
			get_node("/root/Main").hide_menu()
			get_node("/root/Main").show_transfer_menu()
			pass
		else:
			# search the obstacle for an inventory
			pass
		return
	var actor = level_tile.actor
	if actor:
		# not really sure what to do here. Attack?
		return
	var ground = level_tile.ground
	if ground.inventory.keys().size() == 1:
		if ground.inventory[ground.inventory.keys()[0]].count == 1:
			var item_title = ground.inventory.keys()[0]
			Global.level.p.add_item(item_title)
			ground.remove_item(item_title)
			return
		else:
			ground.inventory_panel = transfer_panel_other
			transfer_panel_other.init_display(ground)
			get_node("/root/Main").left_viewport()
			get_node("/root/Main").hide_menu()
			get_node("/root/Main").show_transfer_menu()
	elif ground.inventory.keys().size() > 1:
		ground.inventory_panel = transfer_panel_other
		transfer_panel_other.init_display(ground)
		get_node("/root/Main").left_viewport()
		get_node("/root/Main").hide_menu()
		get_node("/root/Main").show_transfer_menu()
		return


func process_item_control_input():
	var active_item_control = inventory_panel.active_item_control
	var player = Global.level.p
	var item_title = active_item_control.item_title
	var equip_location = active_item_control.equip_location
	var item = Global.level.items[item_title]
	if Input.is_action_just_pressed("left_click"):
		# perform action based on item category:
		# arms: equip
		if item.category == "arms":
			if active_item_control.equip_location == "left":
				player.unequip_hand("left")
			elif active_item_control.equip_location == "right":
				player.unequip_hand("right")
				player.equip_item(item_title,"left")
			else:
				player.equip_item(item_title,"left")
		# aid: consume
		# ammo: nothing
		# docs: read
		# keys: nothing
		pass
	elif Input.is_action_just_pressed("right_click"):
		if item.category == "arms":
			if active_item_control.equip_location == "right":
				player.unequip_hand("right")
			elif active_item_control.equip_location == "left":
				player.unequip_hand("left")
				player.equip_item(item_title,"right")
			else:
				player.equip_item(item_title,"right")
		pass
	elif Input.is_action_just_released("drop_inventory_item"):
		# pressing R (by default) should drop the item on the ground.
		if active_item_control.equip_location != "none":
			player.drop_equipped_item(active_item_control.equip_location)
		else:
			player.drop_item(item_title)


func process_transfer_control_input():
	var source
	var target
	var active_item_control
	if active_transfer_panel == "player":
		active_item_control = transfer_panel_player.active_item_control
		source = transfer_panel_player.entity
		target = transfer_panel_other.entity
	elif active_transfer_panel == "other":
		active_item_control = transfer_panel_other.active_item_control
		source = transfer_panel_other.entity
		target = transfer_panel_player.entity
	var item_title = active_item_control.item_title
	if Input.is_action_just_pressed("left_click"):
		if active_item_control.equip_location == "none":
			source.transfer_item(item_title,target)
		else:
			source.transfer_hand(active_item_control.equip_location,target)
		transfer_panel_player.active_item_control = false
		transfer_panel_other.active_item_control = false
	pass


func neighbouring_tiles(tile1, tile2):
	if ((tile1.x == tile2.x
	  || tile1.x == tile2.x+1
	  || tile1.x == tile2.x-1)
	 && (tile1.y == tile2.y
	  || tile1.y == tile2.y+1
	  || tile1.y == tile2.y-1)):
		return true
	return false
