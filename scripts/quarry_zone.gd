extends Node2D

@export var quarry_position_a: Vector2 = Vector2(4250, 100)
@export var quarry_position_b: Vector2 = Vector2(250, -250)

func _ready():
	var player = get_node("/root/Player")
	if Globals.current_zone == "ForestZone":
		player.position = quarry_position_a
		Globals.current_zone = "QuarryZone"
		print("From forest zone")
	elif Globals.current_zone == "AirplaneZone":
		player.position = quarry_position_b
		Globals.current_zone = "QuarryZone"
		print("From airplane zone")

func _process(_delta):
	pass

func _on_ZoneTransitionA_body_entered(body: Node) -> void:
	if body is Player:
		load_new_zone()

func load_new_zone() -> void:
	print("Going to forest")
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestZone.tscn")

func _on_ZoneTransitionB_body_entered(body: Node) -> void:
	if body is Player:
		load_new_zone_b()

func load_new_zone_b() -> void:
	print("Going to airplane zone")
	call_deferred("change_scene_b")

func change_scene_b() -> void:
	get_tree().change_scene_to_file("res://scenes/AirplaneZone.tscn")
