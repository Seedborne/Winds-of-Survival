extends Node2D

@export var respawn_time: float = 30.0
@export var collection_time: float = 5.0
@export var min_distance_between_resources: float = 250.0

var berries_in_bush = load("res://assets/berrybush.png")
var berriless_bush = load("res://assets/bush.png")

var is_available: bool = true
var is_collecting: bool = false
var collection_timer: float = 0.0

func _ready() -> void:
	$BushSprite.set_texture(berries_in_bush)

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

func _on_bush_area_body_entered(body: Node) -> void:
	if body is Player and is_available and $BushSprite.texture == berries_in_bush:
		$InteractLabel.show()

func _on_bush_area_body_exited(body: Node) -> void:
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
	$BushSprite.set_texture(berriless_bush)
	var random_amount = randi_range(4, 7)
	if Globals.add_item_to_inventory("berry", random_amount):
		print("Collected ", random_amount, " berries.")
		is_available = false
		await get_tree().create_timer(respawn_time).timeout
		respawn_resource()
	else:
		print("Inventory full, couldn't collect berries.")

func respawn_resource() -> void:
	is_available = true
	$BushSprite.set_texture(berries_in_bush)
	print("Bush respawned")
