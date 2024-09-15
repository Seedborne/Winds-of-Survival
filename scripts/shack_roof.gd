extends Sprite2D

@export var upgrade_levels = [
	{"level": "broken", "next": "wood", "cost": {"wood": 6}, "sprite": "res://assets/Brokenroof.png"},
	{"level": "wood", "next": "stone", "cost": {"stone": 6}, "sprite": "res://assets/Woodroof.png"},
	{"level": "stone", "next": "metal", "cost": {"metal": 6}, "sprite": "res://assets/Stoneroof.png"},
	{"level": "metal", "next": "", "cost": null, "sprite": "res://assets/Metalroof.png"}
]
@export var upgrade_duration: float = 2.0
var upgrade_timer: float = 0.0
var upgrading: bool = false
var current_level_index: int = 0 
var player_in_area: bool = false

func _ready():
	current_level_index = Globals.roof_index
	update_sprite()
	
func _process(delta: float) -> void:
	var root = get_parent()
	var upgrading_wood = root.get_node("UpgradingWood")
	var upgrading_stone = root.get_node("UpgradingStone")
	var upgrading_metal = root.get_node("UpgradingMetal")
	if player_in_area and Input.is_action_just_pressed("interact") and check_upgrade_affordability():
		if current_level_index == 0: 
			upgrading_wood.play()
		if current_level_index == 1:
			upgrading_stone.play()
		if current_level_index == 2:
			upgrading_metal.play()
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
	Globals.roof_index += 1
	if current_level_index == 1:
		Globals.shack_strength += 10
		$RoofLabel.text = "Upgrade roof 
		for 6 stone"
		if Globals.tutorial_mode_on:
			$RoofLabel.text = "Upgrade roof 
			for 6 stone
			(Hold E)"
	if current_level_index == 2:
		Globals.shack_strength += 30
		$RoofLabel.text = "Upgrade roof 
		for 6 metal"
		if Globals.tutorial_mode_on:
			$RoofLabel.text = "Upgrade roof 
			for 6 metal
			(Hold E)"
	if current_level_index == 3:
		Globals.shack_strength += 50
		$RoofLabel.text = ""
		$RoofLabel.hide()
		$RoofDot.hide()
	print("Shack strength: ", Globals.shack_strength)

func complete_upgrade() -> void:
	if current_level_index < upgrade_levels.size() - 1:
		deduct_resources()
		update_sprite()
		print("Upgraded to", upgrade_levels[current_level_index]["level"])
		upgrade_timer = 0.0
		upgrading = false
		if current_level_index == 3:
			$RoofDot.hide()

func update_sprite() -> void:
	var current_level = upgrade_levels[current_level_index]
	set_texture(load(current_level["sprite"]))

func _on_roof_area_2d_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true
		$RoofDot.hide()
		if current_level_index < upgrade_levels.size() - 1:
			var current_level = upgrade_levels[current_level_index]
			check_upgrade_affordability()
			print("Upgrade cost: ", current_level["cost"])
			if current_level_index == 0:
				$RoofLabel.text = "Upgrade roof 
				for 6 wood"
				if Globals.tutorial_mode_on:
					$RoofLabel.text = "Upgrade roof 
					for 6 wood
					(Hold E)"
				$RoofLabel.show()
			if current_level_index == 1:
				$RoofLabel.text = "Upgrade roof 
				for 6 stone"
				if Globals.tutorial_mode_on:
					$RoofLabel.text = "Upgrade roof 
					for 6 stone
					(Hold E)"
				$RoofLabel.show()
			if current_level_index == 2:
				$RoofLabel.text = "Upgrade roof 
				for 6 metal"
				if Globals.tutorial_mode_on:
					$RoofLabel.text = "Upgrade roof 
					for 6 metal
					(Hold E)"
				$RoofLabel.show()
			if current_level_index == 3:
				$RoofLabel.text = ""
				$RoofLabel.hide()
			if check_upgrade_affordability():
				print("Can afford upgrade!")
			else:
				print("Cannot afford upgrade.")

func _on_roof_area_2d_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false
		upgrade_timer = 0.0
		upgrading = false
		$RoofLabel.hide()
		if current_level_index < upgrade_levels.size() - 1:
			$RoofDot.show()
