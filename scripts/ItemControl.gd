extends ColorRect
var index
var item_title
var equip_location = false # if item is equipped, the equip location is put here

func _ready():
	connect("mouse_entered", self, "set_active")
	connect("mouse_exited", self, "unset_active")


func set_active():
	color = Color("#666666")
	Global.input_handler.active_item_control = self


func unset_active():
	color = Color("#000000")
	Global.input_handler.active_item_control = false
