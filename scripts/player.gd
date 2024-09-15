extends CharacterBody2D

@export var walk_speed: float = 250.0
@export var run_speed: float = 400.0
@export var left_limit: float = 0.0
@export var right_limit: float = 1150.0
@export var top_limit: float = -475.0
@export var bottom_limit: float = 1125.0
@export var max_stamina: float = 100.0
@export var current_stamina: float = max_stamina
@export var stamina_drain_rate: float = 8.0
@export var stamina_refuel_rate: float = 1.0
@export var can_run: bool = true

var animated_sprite: AnimatedSprite2D
var last_direction: Vector2 = Vector2(0, 1)
var is_movement_enabled: bool = true

func _ready():
	animated_sprite = $PlayerSprite

func _process(delta: float) -> void:
	if is_movement_enabled:
		var direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		var is_running = Input.is_action_pressed("run") and current_stamina > 0
		if Input.is_action_pressed("left"):
			direction.x -= 1
			last_direction = direction
		elif Input.is_action_pressed("right"):
			direction.x += 1
			last_direction = direction
		if Input.is_action_pressed("up"):
			direction.y -= 1
			last_direction = direction
		elif Input.is_action_pressed("down"):
			direction.y += 1
			last_direction = direction
		if direction.length() > 0:
			direction = direction.normalized()
		if is_running and can_run:
			if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
				drain_stamina(delta)
			if current_stamina > 1:
				is_running = true
				velocity = direction * run_speed
			else:
				is_running = false
				velocity = direction * walk_speed
		else:
			is_running = false
			velocity = direction * walk_speed
			refuel_stamina(delta)
		update_animation()
		move_and_slide()
		if Globals.current_zone == "ShackZone":
			left_limit = 0.0
			right_limit = 1150.0
			top_limit = -475.0
			bottom_limit = 1050.0
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

func update_animation():
	var is_running = Input.is_action_pressed("run") and current_stamina > 0
	if velocity == Vector2.ZERO:
		if last_direction.x < 0:
			animated_sprite.play("idle_left")
		elif last_direction.x > 0:
			animated_sprite.play("idle_right")
		elif last_direction.y > 0:
			animated_sprite.play("idle_down")
		elif last_direction.y < 0:
			animated_sprite.play("idle_up")
	else:
		if last_direction.x < 0:
			animated_sprite.play("walk_left")
		elif last_direction.x > 0:
			animated_sprite.play("walk_right")
		elif last_direction.y < 0:
			animated_sprite.play("walk_up")
		else:
			animated_sprite.play("walk_down")
		var animation_speed = 1.6 if is_running else 1.3
		animated_sprite.speed_scale = animation_speed

func drain_stamina(delta: float) -> void:
	current_stamina -= stamina_drain_rate * delta
	if current_stamina <= 0:
		current_stamina = 0
		can_run = false

func refuel_stamina(delta: float) -> void:
	if current_stamina < max_stamina:
		current_stamina += stamina_refuel_rate * delta
		if current_stamina > max_stamina:
			current_stamina = max_stamina
	if current_stamina > 0:
		can_run = true
