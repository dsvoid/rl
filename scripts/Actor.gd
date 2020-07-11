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

func _ready():
	$Sprite/LeftArm.region_rect = Global.level.equip_arms["unarmed2"]
	$Sprite/RightArm.region_rect = Global.level.equip_arms["unarmed2"]


func equip_item(item_title, hand):
	var equip_sprite
	if !inventory.has(item_title):
		return false
	remove_item(item_title)
	if inventory.has(item_title) && inventory_panel:
		inventory_panel.update_item_control_count_by_title(item_title)
	unequip_hand("both")
	if hand == "left":
		equip_sprite = $Sprite/LeftArm
		unequip_hand("left")
	elif hand == "right":
		equip_sprite = $Sprite/RightArm
		unequip_hand("right")
	elif hand == "both":
		equip_sprite = $Sprite/LeftArm
		unequip_hand("left")
		unequip_hand("right")
	hands[hand] = item_title
	# draw item on hand
	equip_sprite.region_rect = Global.level.equip_arms[item_title]
	if inventory_panel:
		inventory_panel.add_item_control(item_title,hand)
	if transfer_panel:
		transfer_panel.add_item_control(item_title,hand)


func unequip_hand(hand):
	if !hands[hand]:
		return false
	var equip_sprite
	if hand == "left" || hand == "both":
		$Sprite/LeftArm.region_rect = Global.level.equip_arms["unarmed2"]
	elif hand == "right":
		$Sprite/RightArm.region_rect = Global.level.equip_arms["unarmed2"]
	var item_title = hands[hand]
	hands[hand] = false
	if inventory_panel:
		inventory_panel.remove_item_control(item_title,hand)
	if transfer_panel:
		transfer_panel.remove_item_control(item_title,hand)
	add_item(item_title)
	return item_title


func drop_equipped_item(hand):
	var item_title = unequip_hand(hand)
	drop_item(item_title)


func transfer_hand(hand,target):
	var item_title = hands[hand]
	unequip_hand(hand)
	transfer_item(item_title,target)
