extends Node

var current_zone = "ShackZone"
var new_game = true
var inventory = [
	{"item": null, "count": 0, "item_tag": null},
	{"item": null, "count": 0, "item_tag": null},
	{"item": null, "count": 0, "item_tag": null},
	{"item": null, "count": 0, "item_tag": null}
]
const MAX_STACK_SIZE = 10
var shack_strength = 0
var level_index = 0

func _ready():
	pass

func _process(_delta):
	pass

func add_item_to_inventory(item_type: String, quantity: int) -> bool:
	var item_tag = null
	print(item_type)
	if item_type == "berry" or item_type == "rabbit" or item_type == "crab":
		item_tag = "food"
	print("Attempting to add ", quantity, " ", item_type, " to inventory.")
	for slot in inventory:
		if slot["item"] == item_type and slot["count"] < MAX_STACK_SIZE:
			var remaining_space = MAX_STACK_SIZE - slot["count"]
			var added_quantity = min(remaining_space, quantity)
			slot["count"] += added_quantity
			quantity -= added_quantity
			if quantity == 0:
				UI.update_inventory_ui()
				return true
	for slot in inventory:
		if slot["item"] == null:
			slot["item"] = item_type
			slot["item_tag"] = item_tag
			slot["count"] = min(quantity, MAX_STACK_SIZE)
			quantity -= slot["count"]
			if quantity == 0:
				UI.update_inventory_ui()
				return true
	UI.update_inventory_ui()
	return false

func remove_item_from_inventory(slot_index: int, quantity: int) -> bool:
	var slot = inventory[slot_index]
	if slot["item"] != null and slot["count"] >= quantity:
		slot["count"] -= quantity
		if slot["count"] == 0:
			slot["item"] = null
			slot["item_tag"] = null
			UI.update_inventory_ui()
		UI.update_inventory_ui()
		return true
	UI.update_inventory_ui()
	return false

func print_inventory():
	for i in range(len(inventory)):
		print("Slot", i+1, ":", inventory[i])
