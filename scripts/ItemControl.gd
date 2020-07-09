extends ColorRect
var item_title
var equip_location

func _ready():
	connect("mouse_entered", self, "set_active")
	connect("mouse_exited", self, "unset_active")


func set_active():
	color = Color("#666666")
	get_parent().active_item_control = self


func unset_active():
	color = Color("#000000")
	get_parent().active_item_control = false
