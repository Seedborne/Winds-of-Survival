extends Sprite2D

@export var upgrade_levels = [
	{"level": "broken", "next": "wood", "cost": {"wood": 10}, "sprite": "res://assets/brokenwall1.png"},
	{"level": "wood", "next": "stone", "cost": {"stone": 8}, "sprite": "res://assets/wall1wood.png"},
	{"level": "stone", "next": "metal", "cost": {"metal": 5}, "sprite": "res://assets/stonewall1.png"},
	{"level": "metal", "next": "", "cost": null, "sprite": "res://assets/metalwall1.png"}
]
@export var upgrade_duration: float = 5.0
var upgrade_timer: float = 0.0
var upgrading: bool = false
var current_level_index: int = 0 
var player_in_area: bool = false

func _ready():
	current_level_index = Globals.level_index
	update_sprite()
	
func _process(delta: float) -> void:
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
	for resource in current_level["cost"].keys():
		var cost = current_level["cost"][resource]
		if not has_enough_resource(resource, cost):
			print("Cannot afford upgrade.")
			return false
	print("Can afford upgrade!")
	return true

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
	Globals.level_index += 1
	if current_level_index == 1:
		$Wall1Label.text = "Upgrade wall for 8 stone"
	if current_level_index == 2:
		$Wall1Label.text = "Upgrade wall for 5 metal"
	if current_level_index == 3:
		$Wall1Label.text = ""
		$Wall1Label.hide()

func complete_upgrade() -> void:
	if current_level_index < upgrade_levels.size() - 1:
		deduct_resources()
		update_sprite()
		print("Upgraded to", upgrade_levels[current_level_index]["level"])
		upgrade_timer = 0.0
		upgrading = false

func update_sprite() -> void:
	var current_level = upgrade_levels[current_level_index]
	set_texture(load(current_level["sprite"]))

func _on_Wall1Area2D_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true
		if current_level_index < upgrade_levels.size():
			var current_level = upgrade_levels[current_level_index]
			check_upgrade_affordability()
			print("Upgrade cost: ", current_level["cost"])
			print(current_level_index)
			if current_level_index == 0:
				$Wall1Label.text = "Upgrade wall for 10 wood"
				$Wall1Label.show()
			if current_level_index == 1:
				$Wall1Label.text = "Upgrade wall for 8 stone"
				$Wall1Label.show()
			if current_level_index == 2:
				$Wall1Label.text = "Upgrade wall for 5 metal"
				$Wall1Label.show()
			if current_level_index == 3:
				$Wall1Label.text = ""
				$Wall1Label.hide()

func _on_wall_1_area_2d_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false
		upgrade_timer = 0.0
		upgrading = false
		$Wall1Label.hide()
