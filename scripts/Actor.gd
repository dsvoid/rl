extends Entity
class_name Actor

var humanoid = false # flag for accessible human behaviours like equipping items
var one_handed = false # checks if actor can only equip items in one hand
var wide = false # checks where to draw arms given sprite width

# reference to items in hands
var hands = {
	"left": false,
	"right": false,
	"both": false
}

func equip_item(item_title, hand):
	if !inventory.has(item_title):
		return false
	remove_item(item_title)
	if inventory.has(item_title) && inventory_panel:
		inventory_panel.update_item_control_count_by_title(item_title)
	unequip_hand("both")
	if hand == "left":
		unequip_hand("left")
	if hand == "right":
		unequip_hand("right")
	elif hand == "both":
		unequip_hand("left")
		unequip_hand("right")
	hands[hand] = item_title
	if inventory_panel:
		inventory_panel.add_item_control(item_title,hand)


func unequip_hand(hand):
	if hands[hand]:
		var item_title = hands[hand]
		hands[hand] = false
		if inventory_panel:
			inventory_panel.remove_item_control(item_title,hand)
		add_item(item_title)
		return item_title


func drop_equipped_item(hand):
	var item_title = unequip_hand(hand)
	drop_item(item_title)
