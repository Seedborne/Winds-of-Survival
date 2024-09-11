extends CharacterBody2D

@export var walk_speed: float = 200.0
@export var run_speed: float = 300.0
@export var left_limit: float = 0.0
@export var right_limit: float = 1150.0
@export var top_limit: float = -475.0
@export var bottom_limit: float = 1125.0

var fisherman_left = load("res://assets/fishermanleft.png")
var fisherman_right = load("res://assets/fishermanright.png")

func _ready():
	pass

func _process(_delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("left"):
		direction.x -= 1
		$PlayerSprite.set_texture(fisherman_left)
	if Input.is_action_pressed("right"):
		direction.x += 1
		$PlayerSprite.set_texture(fisherman_right)
	if Input.is_action_pressed("up"):
		direction.y -= 1
		$PlayerSprite.set_texture(fisherman_right)
	if Input.is_action_pressed("down"):
		direction.y += 1
		$PlayerSprite.set_texture(fisherman_left)
	if direction.length() > 0:
		direction = direction.normalized()
	if Input.is_action_pressed("run"):
		velocity = direction * run_speed
	else:
		velocity = direction * walk_speed
	move_and_slide()
	if Globals.current_zone == "ShackZone":
		left_limit = 0.0
		right_limit = 1150.0
		top_limit = -475.0
		bottom_limit = 1125.0
	elif Globals.current_zone == "ForestZone":
		left_limit = 0.0
		right_limit = 3360
		top_limit = -1750
		bottom_limit = 450.0
	elif Globals.current_zone == "QuarryZone":
		left_limit = 0.0
		right_limit = 3360
		top_limit = -1750
		bottom_limit = 450.0
	elif Globals.current_zone == "AirplaneZone":
		left_limit = 0.0
		right_limit = 3360
		top_limit = -1750
		bottom_limit = 450.0
	position.x = clamp(position.x, left_limit, right_limit)
	position.y = clamp(position.y, top_limit, bottom_limit)
