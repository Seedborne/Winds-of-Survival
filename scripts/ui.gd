extends CanvasLayer

var icon = load("res://assets/icon.svg")

func _ready():
	pass

func _process(_delta):
	update_stamina_bar()
	
func _input(_event):
	if Input.is_action_pressed("backpack"):
		_on_backpack_button_pressed()
	if Input.is_action_pressed("1slot") and $BackpackUI.visible and not $BackpackUI/Slot1.disabled:
		_on_Slot1_pressed()
	if Input.is_action_pressed("2slot") and $BackpackUI.visible and not $BackpackUI/Slot2.disabled:
		_on_Slot2_pressed()
	if Input.is_action_pressed("3slot") and $BackpackUI.visible and not $BackpackUI/Slot3.disabled:
		_on_Slot3_pressed()
	if Input.is_action_pressed("4slot") and $BackpackUI.visible and not $BackpackUI/Slot4.disabled:
		_on_Slot4_pressed()

func _on_backpack_button_pressed():
	$BackpackUI.visible = !$BackpackUI.visible

func update_inventory_ui():
	Globals.print_inventory()
	for i in range(len(Globals.inventory)):
		var slot = Globals.inventory[i]
		var slot_label = $BackpackUI.get_node("SlotLabel" + str(i+1)) as Label
		var slot_button = $BackpackUI.get_node("Slot" + str(i+1)) as TextureButton
		if slot["item"] != null:
			slot_label.text = "Qty: " + str(slot["count"])
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
		var item_type = slot["item"]
		if Globals.remove_item_from_inventory(0, 1):
			recover_stamina(item_type)
			print("Ate food, regained stamina!")
	else:
		if Globals.remove_item_from_inventory(0, 1):
			print("Item discarded.")

func _on_Slot2_pressed():
	var slot = Globals.inventory[1]
	if slot["item_tag"] == "food":
		var item_type = slot["item"]
		if Globals.remove_item_from_inventory(1, 1):
			recover_stamina(item_type)
			print("Ate food, regained stamina!")
	else:
		if Globals.remove_item_from_inventory(1, 1):
			print("Item discarded.")

func _on_Slot3_pressed():
	var slot = Globals.inventory[2]
	if slot["item_tag"] == "food":
		var item_type = slot["item"]
		if Globals.remove_item_from_inventory(2, 1):
			recover_stamina(item_type)
			print("Ate food, regained stamina!")
	else:
		if Globals.remove_item_from_inventory(2, 1):
			print("Item discarded.")

func _on_Slot4_pressed():
	var slot = Globals.inventory[3]
	if slot["item_tag"] == "food":
		var item_type = slot["item"]
		if Globals.remove_item_from_inventory(3, 1):
			recover_stamina(item_type)
			print("Ate food, regained stamina!")
	else:
		if Globals.remove_item_from_inventory(3, 1):
			print("Item discarded.")

func recover_stamina(item_type: String) -> void:
	match item_type:
		"berry":
			Player.current_stamina += 10
		"crab":
			Player.current_stamina += 30
		"rabbit":
			Player.current_stamina += 50
	Player.current_stamina = min(Player.current_stamina, Player.max_stamina)
	print("Stamina recovered!")

func update_stamina_bar():
	var stamina_bar = get_node("/root/UI/StaminaBar")
	stamina_bar.value = Player.current_stamina / Player.max_stamina * 100

func _on_settings_button_pressed():
	if not SettingsLayer.visible:
		SettingsLayer.show()
		get_tree().paused = true
	else:
		SettingsLayer.hide()
		get_tree().paused = false
