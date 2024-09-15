extends Node

var current_zone = "ShackZone"
var new_game = true
var timer_mode_on = false
var tutorial_mode_on = true
var inventory = [
	{"item": null, "count": 0, "item_tag": null},
	{"item": null, "count": 0, "item_tag": null},
	{"item": null, "count": 0, "item_tag": null},
	{"item": null, "count": 0, "item_tag": null}
]
const MAX_STACK_SIZE = 20

var difficulty = "normal"
var shack_strength = 0
var storm_strength = 100

var heat_points = 0
var heat_needed = 10
var food_points = 0
var food_needed = 30

var wall1_index = 0
var wall2_index = 0
var wall3_index = 0
var wall4_index = 0
var window1_index = 0
var window2_index = 0
var roof_index = 0
var door_index = 0

var win_status = ""
var player_inside = false
var shack_destroyed = false
var shack_survived = false
var stayed_warm = false
var froze_to_death = false
var enough_food = false
var starved_to_death = false

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
		return true
	UI.update_inventory_ui()
	return false

func print_inventory():
	for i in range(len(inventory)):
		print("Slot", i+1, ":", inventory[i])

func reset_game_state():
	new_game = true
	shack_strength = 0
	heat_points = 0
	food_points = 0
	wall1_index = 0
	wall2_index = 0
	wall3_index = 0
	wall4_index = 0
	window1_index = 0
	window2_index = 0
	roof_index = 0
	door_index = 0
	win_status = ""
	player_inside = false
	shack_destroyed = false
	shack_survived = false
	stayed_warm = false
	froze_to_death = false
	enough_food = false
	starved_to_death = false
	for slot in inventory:
		slot["item"] = null
		slot["count"] = 0
		slot["item_tag"] = null
	UI.update_inventory_ui()
