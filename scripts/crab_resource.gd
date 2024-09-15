extends Node2D

@export var respawn_time: float = 60.0
@export var min_distance_between_resources: float = 200.0

var is_available: bool = true
var near_resource: bool = false

func _ready() -> void:
	$CrabSprite.play("crawl")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and near_resource and is_available:
		complete_collection()
		$CrabAudio.play()

func _on_crab_area_body_entered(body: Node) -> void:
	if body is Player and is_available:
		near_resource = true
		if Globals.tutorial_mode_on:
			$InteractLabel.show()

func _on_crab_area_body_exited(body: Node) -> void:
	if body is Player:
		near_resource = false
		$InteractLabel.visible = false

func complete_collection() -> void:
	print("Resource collected!")
	$InteractLabel.visible = false
	collect_resource()

func collect_resource() -> void:
	$CrabSprite.visible = false
	$CrabArea/CrabCollision.disabled = true
	$StaticBody2D/CollisionShape2D.disabled = true
	var random_amount = randi_range(1, 2)
	if Globals.add_item_to_inventory("crab", random_amount):
		print("Collected ", random_amount, " crab.")
	else:
		print("Inventory full, couldn't collect crab.")
	is_available = false
	await get_tree().create_timer(respawn_time).timeout
	respawn_resource()

func respawn_resource() -> void:
	is_available = true
	$CrabSprite.visible = true
	$CrabArea/CrabCollision.disabled = false
	$StaticBody2D/CollisionShape2D.disabled = false
	print("Crab respawned")
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
		print("Warning: Could not find a valid position for Crab after ", max_attempts, " attempts.")

func is_valid_spawn_position(new_position: Vector2) -> bool:
	for child in get_parent().get_children():
		if child.is_in_group("resources") and child != self:
			var distance = new_position.distance_to(child.position)
			if distance < min_distance_between_resources:
				return false
	return true
