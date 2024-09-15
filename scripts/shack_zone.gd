extends Node2D

@export var player_spawn_position: Vector2 = Vector2(800, 1000)
@export var shack_position_a: Vector2 = Vector2(1000, -250)
@export var num_crabs: int = 2
@export var num_bottles: int = 3
@export var crab_scene: PackedScene
@export var glass_scene: PackedScene
@export var min_distance_between_resources: float = 250.0

var valid_spawn_areas: Array

func _ready():
	valid_spawn_areas = [ $SpawnArea1, $SpawnArea2 ]
	crab_scene = load("res://scenes/CrabResource.tscn")
	glass_scene = load("res://scenes/GlassResource.tscn")
	spawn_resources(crab_scene, num_crabs)
	spawn_resources(glass_scene, num_bottles)
	var player = get_node("/root/Player")
	Globals.current_zone = "ShackZone"
	Globals.player_inside = false
	$ShackOutside.visible = true
	$ShackInside.visible = false
	$ShackRubble.visible = false
	is_outside()
	if Globals.new_game:
		Globals.player_inside = false
		player.position = player_spawn_position
		Globals.new_game = false
		print("New game started")
		if Globals.tutorial_mode_on:
			$TutorialArrow.show()
			$TutorialArrow2.show()
	else:
		Globals.player_inside = false
		player.position = shack_position_a
		print("From forest zone")
	if Globals.player_inside:
		$ShackOutside.visible = false
		$ShackInside.visible = true
	else:
		$ShackOutside.visible = true
		$ShackInside.visible = false

func _process(_delta):
	if Globals.win_status == "made_it_inside":
		$ShackOutside.visible = true
		$ShackInside.visible = false
	elif Globals.win_status == "player_won":
		$ShackOutside.visible = false
		$ShackInside.visible = true
	elif Globals.win_status == "shack_destroyed":
		$ShackRubble.visible = true
		$ShackOutside.visible = false
		$ShackInside.visible = false
	elif Globals.win_status == "player_froze":
		$ShackOutside.visible = false
		$ShackInside.visible = true
	elif Globals.win_status == "player_starved":
		$ShackOutside.visible = false
		$ShackInside.visible = true

func spawn_resources(resource_scene: PackedScene, amount: int) -> void:
	for i in range(amount):
		var attempts = 0
		var max_attempts = 100
		var resource = resource_scene.instantiate()
		var spawn_position: Vector2
		while attempts < max_attempts:
			spawn_position = get_random_spawn_position()
			if is_valid_spawn_position(spawn_position):
				break 
			attempts += 1
		resource.position = spawn_position
		add_child(resource)
		if attempts == max_attempts:
			print("Warning: Could not find a valid position for ", resource, " after ", max_attempts, " attempts.")

func is_valid_spawn_position(new_position: Vector2) -> bool:
	for child in get_children():
		if child.is_in_group("resources"):
			var distance = new_position.distance_to(child.position)
			if distance < min_distance_between_resources:
				return false
	return true

func get_random_spawn_position() -> Vector2:
	var spawn_area = valid_spawn_areas[randi() % valid_spawn_areas.size()]
	var collision_shape: CollisionShape2D
	match spawn_area.name:
		"SpawnArea1":
			collision_shape = $SpawnArea1/SpawnCollision1
		"SpawnArea2":
			collision_shape = $SpawnArea2/SpawnCollision2
		_:
			print("Error: No matching collision shape for " + spawn_area.name)
			return Vector2.ZERO
	var rect_shape = collision_shape.shape as RectangleShape2D
	var margin = 1.0
	return Vector2(
		randf_range(spawn_area.position.x - rect_shape.extents.x + margin, spawn_area.position.x + rect_shape.extents.x - margin),
		randf_range(spawn_area.position.y - rect_shape.extents.y + margin, spawn_area.position.y + rect_shape.extents.y - margin)
)

func _on_enter_shack_area_body_entered(body):
	if body is Player:
		$ShackOutside.visible = false
		$ShackInside.visible = true
		is_inside()

func _on_exit_shack_area_body_entered(body):
	if body is Player:
		$ShackOutside.visible = true
		$ShackInside.visible = false
		is_outside()

func is_inside():
	Globals.player_inside = true
	$StaticBodyDeck3/CollisionShape2D.call_deferred("set_disabled", false)
	$StaticBodyDeck4/CollisionShape2D.call_deferred("set_disabled", true)
	$ShackOutside/Wall1Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	$ShackOutside/Wall2Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	$ShackOutside/DoorArea2D/CollisionShape2D.call_deferred("set_disabled", true)
	$ShackInside/ChairArea2D/CollisionShape2D.call_deferred("set_disabled", false)
	$ShackInside/ChestArea2D/CollisionShape2D.call_deferred("set_disabled", false)

func is_outside():
	Globals.player_inside = false
	$StaticBodyDeck3/CollisionShape2D.call_deferred("set_disabled", true)
	$StaticBodyDeck4/CollisionShape2D.call_deferred("set_disabled", false)
	$ShackOutside/Wall1Area2D/CollisionShape2D.call_deferred("set_disabled", false)
	$ShackOutside/Wall2Area2D/CollisionShape2D.call_deferred("set_disabled", false)
	$ShackOutside/DoorArea2D/CollisionShape2D.call_deferred("set_disabled", false)
	$ShackInside/ChairArea2D/CollisionShape2D.call_deferred("set_disabled", true)
	$ShackInside/ChestArea2D/CollisionShape2D.call_deferred("set_disabled", true)

func _on_arrow_2_area_2d_body_entered(body):
	if body is Player:
		$TutorialArrow2.visible = false

func _on_arrow_area_2d_body_entered(body):
	if body is Player:
		$TutorialArrow.visible = false

func _on_ZoneTransition_body_entered(body: Node) -> void:
	if body is Player:
		load_new_zone()

func load_new_zone() -> void:
	print("Going to forest")
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestZone.tscn")
