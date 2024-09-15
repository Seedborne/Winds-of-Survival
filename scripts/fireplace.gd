extends Sprite2D

var player_in_area: bool = false

func _process(_delta: float) -> void:
	for i in range(len(Globals.inventory)):
		var slot = Globals.inventory[i]
		if slot["item"] == "coal":
			if player_in_area and Input.is_action_just_pressed("interact"):
				store_coal_in_fireplace()

func store_coal_in_fireplace() -> void:
	var total_coal_stored = 0
	for i in range(len(Globals.inventory)):
		var slot = Globals.inventory[i]
		if slot["item"] == "coal":
			var quantity = slot["count"]
			Globals.heat_points += quantity * 1
			Globals.remove_item_from_inventory(i, quantity)
			print("Stored ", quantity, " coal")
			total_coal_stored += quantity
	if total_coal_stored > 0:
		var root = get_parent()
		var storing_coal = root.get_node("StoreCoal")
		storing_coal.play()
		print("Total heat points:", Globals.heat_points)
	else:
		print("No coal to store.")
	UI.update_inventory_ui()

func _on_fireplace_area_2d_body_entered(body):
	if body is Player:
		player_in_area = true
		$FireplaceDot.hide()
		$FireplaceLabel.show()

func _on_fireplace_area_2d_body_exited(body):
	if body is Player:
		player_in_area = false
		$FireplaceDot.show()
		$FireplaceLabel.hide()
