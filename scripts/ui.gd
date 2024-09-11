extends CanvasLayer

var icon = load("res://assets/icon.svg")

func _ready():
	pass

func _process(_delta):
	pass

func _on_backpack_button_pressed():
	$BackpackUI.visible = !$BackpackUI.visible

func update_inventory_ui():
	Globals.print_inventory()
	for i in range(len(Globals.inventory)):
		var slot = Globals.inventory[i]
		var slot_label = $BackpackUI.get_node("SlotLabel" + str(i+1)) as Label
		var slot_button = $BackpackUI.get_node("Slot" + str(i+1)) as TextureButton
		if slot["item"] != null:
			slot_label.text = str(slot["count"])
			slot_button.disabled = false
			if slot["item"] == "wood":
				slot_button.texture_normal = icon
			elif slot["item"] == "stone":
				slot_button.texture_normal = icon
			elif slot["item"] == "coal":
				slot_button.texture_normal = icon
			elif slot["item"] == "berry":
				slot_button.texture_normal = icon
		else:
			slot_label.text = "" 
			slot_button.texture_normal = null
			slot_button.disabled = true

func _on_Slot1_pressed():
	var slot = Globals.inventory[0]
	if slot["item_tag"] == "food":
		if Globals.remove_item_from_inventory(0, 1):
			recover_stamina()
			print("Ate food, regained stamina!")
	else:
		print("This item is not edible.")

func _on_Slot2_pressed():
	var slot = Globals.inventory[1]
	if slot["item_tag"] == "food":
		if Globals.remove_item_from_inventory(1, 1):
			recover_stamina()
			print("Ate food, regained stamina!")
	else:
		print("This item is not edible.")

func _on_Slot3_pressed():
	var slot = Globals.inventory[2]
	if slot["item_tag"] == "food":
		if Globals.remove_item_from_inventory(2, 1):
			recover_stamina()
			print("Ate food, regained stamina!")
	else:
		print("This item is not edible.")

func _on_Slot4_pressed():
	var slot = Globals.inventory[3]
	if slot["item_tag"] == "food":
		if Globals.remove_item_from_inventory(3, 1):
			recover_stamina()
			print("Ate food, regained stamina!")
	else:
		print("This item is not edible.")

func recover_stamina():
	# Stamina recovery logic
	print("Stamina recovered!")
