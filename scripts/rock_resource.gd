extends Node2D

@export var respawn_time: float = 60.0
@export var collection_time: float = 2.0
@export var min_distance_between_resources: float = 250.0

var rock1 = preload("res://assets/rock1.png")
var rock2 = preload("res://assets/rock2.png")
var is_available: bool = true
var is_collecting: bool = false
var collection_timer: float = 0.0
var near_resource: bool = false

func _ready() -> void:
	set_random_texture()

func _process(delta: float) -> void:
	if is_collecting:
		if Input.is_action_pressed("interact"):
			collection_timer += delta
			if collection_timer >= collection_time:
				complete_collection()
		else:
			reset_collection()
	if Input.is_action_just_pressed("interact") and near_resource and is_available:
		start_collection()

func set_random_texture():
	if randi_range(0, 1) == 0:
		$RockSprite.texture = rock1
	else:
		$RockSprite.texture = rock2

func _on_rock_area_body_entered(body: Node) -> void:
	if body is Player and is_available:
		near_resource = true
		if Globals.tutorial_mode_on:
			$InteractLabel.show()

func _on_rock_area_body_exited(body: Node) -> void:
	if body is Player:
		near_resource = false
		$InteractLabel.visible = false
		reset_collection()

func start_collection() -> void:
	is_collecting = true
	collection_timer = 0.0
	$RockAudio.play()
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
	$RockSprite.visible = false
	$RockArea/RockCollision.disabled = true
	$StaticBody2D/CollisionShape2D.disabled = true
	var stone_amount = randi_range(2, 5)
	var coal_amount = randi_range(1, 2)
	if Globals.add_item_to_inventory("stone", stone_amount):
		print("Collected ", stone_amount, " stone.")
	else:
		print("Inventory full, couldn't collect stone.")
	if Globals.add_item_to_inventory("coal", coal_amount):
		print("Collected ", coal_amount, " coal.")
	else:
		print("Inventory full, couldn't collect coal.")
	is_available = false
	await get_tree().create_timer(respawn_time).timeout
	respawn_resource()

func respawn_resource() -> void:
	is_available = true
	set_random_texture()
	$RockSprite.visible = true
	$RockArea/RockCollision.disabled = false
	$StaticBody2D/CollisionShape2D.disabled = false
	print("Rock respawned")
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
		print("Warning: Could not find a valid position for Rock after ", max_attempts, " attempts.")

func is_valid_spawn_position(new_position: Vector2) -> bool:
	for child in get_parent().get_children():
		if child.is_in_group("resources") and child != self:
			var distance = new_position.distance_to(child.position)
			if distance < min_distance_between_resources:
				return false
	return true
