extends Node2D

@export var airplane_position_a: Vector2 = Vector2(3150, -175)
@export var num_metal: int = 16
@export var metal_scene: PackedScene
@export var min_distance_between_resources: float = 200.0

var valid_spawn_areas: Array

func _ready():
	valid_spawn_areas = [ $SpawnArea1, $SpawnArea2, $SpawnArea3, $SpawnArea4, $SpawnArea5, $SpawnArea6 ]
	metal_scene = load("res://scenes/MetalResource.tscn")
	spawn_resources(metal_scene, num_metal)
	var player = get_node("/root/Player")
	if Globals.current_zone == "QuarryZone":
		player.position = airplane_position_a
		Globals.current_zone = "AirplaneZone"
		print("From quarry zone")

func _process(_delta):
	pass

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
		"SpawnArea3":
			collision_shape = $SpawnArea3/SpawnCollision3
		"SpawnArea4":
			collision_shape = $SpawnArea4/SpawnCollision4
		"SpawnArea5":
			collision_shape = $SpawnArea5/SpawnCollision5
		"SpawnArea6":
			collision_shape = $SpawnArea6/SpawnCollision6
		_:
			print("Error: No matching collision shape for " + spawn_area.name)
			return Vector2.ZERO
	var rect_shape = collision_shape.shape as RectangleShape2D
	var margin = 1.0
	return Vector2(
		randf_range(spawn_area.position.x - rect_shape.extents.x + margin, spawn_area.position.x + rect_shape.extents.x - margin),
		randf_range(spawn_area.position.y - rect_shape.extents.y + margin, spawn_area.position.y + rect_shape.extents.y - margin)
)

func _on_ZoneTransitionA_body_entered(body: Node) -> void:
	if body is Player:
		load_new_zone()

func load_new_zone() -> void:
	print("Going to quarry")
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/QuarryZone.tscn")
