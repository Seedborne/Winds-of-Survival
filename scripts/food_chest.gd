extends Sprite2D

var player_in_area: bool = false

func _process(_delta: float) -> void:
	for i in range(len(Globals.inventory)):
		var slot = Globals.inventory[i]
		if slot["item_tag"] == "food":
			if player_in_area and Input.is_action_just_pressed("interact"):
				store_food_in_chest()

func store_food_in_chest() -> void:
	var total_food_stored = 0
	for i in range(len(Globals.inventory)):
		var slot = Globals.inventory[i]
		if slot["item_tag"] == "food":
			var item_type = slot["item"]
			var quantity = slot["count"]
			if item_type == "berry":
				Globals.food_points += quantity * 1
			elif item_type == "crab":
				Globals.food_points += quantity * 3
			elif item_type == "rabbit":
				Globals.food_points += quantity * 3
			Globals.remove_item_from_inventory(i, quantity)
			print("Stored ", quantity, item_type)
			total_food_stored += quantity
	if total_food_stored > 0:
		var root = get_parent()
		var storing_food = root.get_node("StoreFood")
		storing_food.play()
		print("Total food points:", Globals.food_points)
	else:
		print("No food to store.")
	UI.update_inventory_ui()

func _on_chest_area_2d_body_entered(body):
	if body is Player:
		player_in_area = true
		$ChestDot.hide()
		$ChestLabel.show()

func _on_chest_area_2d_body_exited(body):
	if body is Player:
		player_in_area = false
		$ChestDot.show()
		$ChestLabel.hide()
