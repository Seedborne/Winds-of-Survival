extends Sprite2D

@export var upgrade_levels = [
	{"level": "broken", "next": "glass", "cost": {"glass": 2}, "sprite": "res://assets/insidewindowbroken.png"},
	{"level": "glass", "next": "wood", "cost": {"wood": 2}, "sprite": "res://assets/insidewindow.png"},
	{"level": "wood", "next": "", "cost": null, "sprite": "res://assets/insidewindowreinforced.png"}
]
@export var upgrade_duration: float = 2.0
var upgrade_timer: float = 0.0
var upgrading: bool = false
var current_level_index: int = 0 
var player_in_area: bool = false

func _ready():
	current_level_index = Globals.window2_index
	update_sprite()
	
func _process(delta: float) -> void:
	var root = get_parent()
	var upgrading_windows = root.get_node("UpgradingWindows")
	var upgrading_wood = root.get_node("UpgradingWood")
	if player_in_area and Input.is_action_just_pressed("interact") and check_upgrade_affordability():
		if current_level_index == 0: 
			upgrading_windows.play()
		if current_level_index == 1:
			upgrading_wood.play()
	if player_in_area and Input.is_action_pressed("interact") and check_upgrade_affordability():
		upgrading = true
		upgrade_timer += delta
		if upgrade_timer >= upgrade_duration:
			complete_upgrade()
	else:
		upgrading = false
		upgrade_timer = 0.0

func check_upgrade_affordability() -> bool:
	var current_level = upgrade_levels[current_level_index]
	if current_level_index < upgrade_levels.size() - 1:
		for resource in current_level["cost"].keys():
			var cost = current_level["cost"][resource]
			if not has_enough_resource(resource, cost):
				return false
		return true
	return false

func has_enough_resource(resource: String, required_amount: int) -> bool:
	var total_count = 0
	for slot in Globals.inventory:
		if slot["item"] == resource:
			total_count += slot["count"]
		if total_count >= required_amount:
			return true
	return false

func deduct_resources():
	var current_level = upgrade_levels[current_level_index]
	for resource in current_level["cost"].keys():
		var cost = current_level["cost"][resource]
		for i in range(len(Globals.inventory)):
			var slot = Globals.inventory[i]
			if slot["item"] == resource:
				var to_deduct = min(slot["count"], cost)
				Globals.remove_item_from_inventory(i, to_deduct)
				cost -= to_deduct
				if cost <= 0:
					break
	current_level_index += 1
	Globals.window2_index += 1
	if current_level_index == 1:
		Globals.shack_strength += 5
		$Window2Label.text = "Upgrade window 
		for 2 wood"
		if Globals.tutorial_mode_on:
			$Window2Label.text = "Upgrade window 
			for 2 wood
			(Hold E)"
	if current_level_index == 2:
		Globals.shack_strength += 10
		$Window2Label.text = ""
		$Window2Label.hide()
		$Window2Dot.hide()
	print("Shack strength: ", Globals.shack_strength)

func complete_upgrade() -> void:
	if current_level_index < upgrade_levels.size() - 1:
		deduct_resources()
		update_sprite()
		print("Upgraded to", upgrade_levels[current_level_index]["level"])
		upgrade_timer = 0.0
		upgrading = false
		if current_level_index == 2:
			$Window2Dot.hide()

func update_sprite() -> void:
	var current_level = upgrade_levels[current_level_index]
	set_texture(load(current_level["sprite"]))

func _on_window_2_area_2d_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true
		$Window2Dot.hide()
		if current_level_index < upgrade_levels.size() - 1:
			var current_level = upgrade_levels[current_level_index]
			check_upgrade_affordability()
			print("Upgrade cost: ", current_level["cost"])
			if current_level_index == 0:
				$Window2Label.text = "Upgrade window 
				for 2 glass"
				if Globals.tutorial_mode_on:
					$Window2Label.text = "Upgrade window 
					for 2 glass
					(Hold E)"
				$Window2Label.show()
			if current_level_index == 1:
				$Window2Label.text = "Upgrade window 
				for 2 wood"
				if Globals.tutorial_mode_on:
					$Window2Label.text = "Upgrade window 
					for 2 wood
					(Hold E)"
				$Window2Label.show()
			if current_level_index == 2:
				$Window2Label.text = ""
				$Window2Label.hide()
			if check_upgrade_affordability():
				print("Can afford upgrade!")
			else:
				print("Cannot afford upgrade.")

func _on_window_2_area_2d_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false
		upgrade_timer = 0.0
		upgrading = false
		$Window2Label.hide()
		if current_level_index < upgrade_levels.size() - 1:
			$Window2Dot.show()
