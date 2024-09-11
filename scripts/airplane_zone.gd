extends Node2D

@export var airplane_position_a: Vector2 = Vector2(3150, -175)

func _ready():
	var player = get_node("/root/Player")
	if Globals.current_zone == "QuarryZone":
		player.position = airplane_position_a
		Globals.current_zone = "AirplaneZone"
		print("From quarry zone")

func _process(_delta):
	pass

func _on_ZoneTransitionA_body_entered(body: Node) -> void:
	if body is Player:
		load_new_zone()

func load_new_zone() -> void:
	print("Going to quarry")
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/QuarryZone.tscn")
