extends Node2D

@export var spawn_position: Vector2 = Vector2(800, 1000)
@export var shack_position_a: Vector2 = Vector2(1000, -250)

func _ready():
	var player = get_node("/root/Player")
	Globals.current_zone = "ShackZone"
	$ShackOutside.visible = true
	$ShackInside.visible = false
	is_outside()
	if Globals.new_game:
		player.position = spawn_position
		Globals.new_game = false
		print("New game started")
	else:
		player.position = shack_position_a
		print("From forest zone")

func _process(_delta):
	pass

func _on_enter_shack_area_body_entered(_body):
	$ShackOutside.visible = false
	$ShackInside.visible = true
	is_inside()

func _on_exit_shack_area_body_entered(_body):
	$ShackOutside.visible = true
	$ShackInside.visible = false
	is_outside()

func is_inside():
	$StaticBodyHouse3/CollisionShape2D.call_deferred("set_disabled", true)
	$StaticBodyHouse4/CollisionShape2D.call_deferred("set_disabled", true)
	$StaticBody2D4/CollisionShape2D.call_deferred("set_disabled", true)
	$StaticBody2D7/CollisionShape2D.call_deferred("set_disabled", true)
	$StaticBody2D8/CollisionShape2D.call_deferred("set_disabled", false)
	$StaticBody2D9/CollisionShape2D.call_deferred("set_disabled", true)
	$InsideStaticBody9/CollisionShape2D.call_deferred("set_disabled", false)
	$InsideStaticBody10/CollisionShape2D.call_deferred("set_disabled", false)
	$ShackOutside/Wall1Area2D/CollisionShape2D.call_deferred("set_disabled", true)
	
func is_outside():
	$StaticBodyHouse3/CollisionShape2D.call_deferred("set_disabled", false)
	$StaticBodyHouse4/CollisionShape2D.call_deferred("set_disabled", false)
	$StaticBody2D4/CollisionShape2D.call_deferred("set_disabled", false)
	$StaticBody2D7/CollisionShape2D.call_deferred("set_disabled", false)
	$StaticBody2D8/CollisionShape2D.call_deferred("set_disabled", true)
	$StaticBody2D9/CollisionShape2D.call_deferred("set_disabled", false)
	$InsideStaticBody9/CollisionShape2D.call_deferred("set_disabled", true)
	$InsideStaticBody10/CollisionShape2D.call_deferred("set_disabled", true)
	$ShackOutside/Wall1Area2D/CollisionShape2D.call_deferred("set_disabled", false)
	
func _on_ZoneTransition_body_entered(body: Node) -> void:
	if body is Player:
		load_new_zone()
		
func load_new_zone() -> void:
	print("Going to forest")
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestZone.tscn")
