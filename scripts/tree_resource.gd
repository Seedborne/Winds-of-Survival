extends Node2D

@export var respawn_time: float = 60.0
@export var collection_time: float = 5.0
@export var min_distance_between_resources: float = 250.0

var is_available: bool = true
var is_collecting: bool = false
var collection_timer: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_collecting:
		if Input.is_action_pressed("interact"):
			collection_timer += delta
			if collection_timer >= collection_time:
				complete_collection()
		else:
			reset_collection()
	if Input.is_action_just_pressed("interact") and $InteractLabel.visible and is_available:
		start_collection()

func _on_tree_area_body_entered(body: Node) -> void:
	if body is Player and is_available:
		$InteractLabel.show()
		if Input.is_action_pressed("interact"):
			await get_tree().create_timer(collection_time).timeout
			collect_resource()

func _on_tree_area_body_exited(body: Node) -> void:
	if body is Player:
		$InteractLabel.visible = false
		reset_collection()

func start_collection() -> void:
	is_collecting = true
	collection_timer = 0.0
	print("Player started collecting...")

func reset_collection() -> void:
	is_collecting = false
	collection_timer = 0.0
	print("Collection reset.")

func complete_collection() -> void:
	print("Resource collected!")
	is_collecting = false
	$InteractLabel.visible = false
	collect_resource()

func collect_resource() -> void:
	$TreeSprite.visible = false
	$RootsSprite.visible = false
	$TreeArea/TreeCollision.disabled = true
	$StaticBody2D/CollisionShape2D.disabled = true
	var random_amount = randi_range(2, 5)
	if Globals.add_item_to_inventory("wood", random_amount):
		print("Collected ", random_amount, " wood.")
	else:
		print("Inventory full, couldn't collect wood.")
	is_available = false
	await get_tree().create_timer(respawn_time).timeout
	respawn_resource()

func respawn_resource() -> void:
	is_available = true
	$TreeSprite.visible = true
	$RootsSprite.visible = true
	$TreeArea/TreeCollision.disabled = false
	$StaticBody2D/CollisionShape2D.disabled = false
	print("Tree respawned")
	var attempts = 0
	var max_attempts = 100
	var spawn_position: Vector2
	while attempts < max_attempts:
		spawn_position = get_parent().get_random_spawn_position()
		if is_valid_spawn_position(spawn_position):
			position = spawn_position
			break
		attempts += 1
	if attempts == max_attempts:
		print("Warning: Could not find a valid position for Tree after ", max_attempts, " attempts.")

func is_valid_spawn_position(new_position: Vector2) -> bool:
	for child in get_parent().get_children():
		if child.is_in_group("resources") and child != self:
			var distance = new_position.distance_to(child.position)
			if distance < min_distance_between_resources:
				return false
	return true
