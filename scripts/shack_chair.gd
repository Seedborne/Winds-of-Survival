extends Sprite2D

var chair_texure = preload("res://assets/chair.png")
var player_in_chair = preload("res://assets/dudeinchair.png")
var dead_in_chair = preload("res://assets/deadinchair.png")
var frozen_in_chair = preload("res://assets/frozeninchair.png")
var near_chair: bool = false
var player_sitting: bool = false

func _process(_delta: float) -> void:
	if player_sitting:
		if Input.is_action_just_pressed("interact"):
			texture = chair_texure
			Player.is_movement_enabled = true
			Player.show()
			player_sitting = false
	else:
		if near_chair and Input.is_action_just_pressed("interact"):
			texture = player_in_chair
			Player.is_movement_enabled = false
			Player.hide()
			player_sitting = true
	if Globals.win_status == "player_won":
		texture = player_in_chair
	elif Globals.win_status == "player_froze":
		texture = frozen_in_chair
	elif Globals.win_status == "player_starved":
		texture = dead_in_chair

func _on_chair_area_2d_body_entered(body):
	if body is Player:
		near_chair = true

func _on_chair_area_2d_body_exited(body):
	if body is Player:
		near_chair = false
