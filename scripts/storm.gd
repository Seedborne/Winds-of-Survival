extends CanvasLayer

@export var cloud_scroll_speed: float = 20.0
@export var cloud_max_speed: float = 100.0
@export var wrap_position: float = -1200
@export var reset_position: float = 1939
@export var cloud_start_y: float = -310
@export var cloud_end_y: float = -100.0
@export var darkness_max_opacity: float = 0.7
@export var lightning_min_interval: float = 20.0
@export var lightning_max_interval: float = 30.0
@export var lightning_min_interval_end: float = 2.0
@export var lightning_max_interval_end: float = 12.0
@export var lightning_start_threshold: float = 0.6
@export var storm_duration: float = 300.0
@export var rain_start_time: float = 92.0
@export var rain_max_intensity_time: float = 270.0
@export var gravity_start_y: float = 800.0
@export var gravity_end_y: float = 2000.0
@export var gravity_start_x: float = 0.0
@export var gravity_end_x: float = 500.0

var lightning_timer: float = 0.0
var storm_progress: float = 0.0
var storm_speed = 300
@onready var countdown_label = $StormCountdown
@onready var storm_timer = $StormTimer
@onready var storm_sprite =  $StormPage
var storm_active: bool = false
@onready var cloud_sprite1 = $StormClouds
@onready var cloud_sprite2 = $StormClouds2
@onready var darkness_layer = $StormDarkness
@onready var storm_music = $StormMusic
@onready var storm_audio = $StormAudio
@onready var rain_audio = $RainAudio
@onready var wind_audio = $WindAudio
@onready var rain_particles = $RainParticles
var previous_emission_amount: float = -1.0
var previous_gravity_x: float = -1.0
var previous_gravity_y: float = -1.0

func _ready() -> void:
	rain_particles.emitting = false
	storm_music.volume_db = -8
	storm_music.play()
	storm_audio.volume_db = -20
	storm_audio.play()
	rain_audio.volume_db = -25
	rain_audio.play()
	wind_audio.volume_db = -27
	wind_audio.play()
	cloud_sprite1.position.y = cloud_start_y
	cloud_sprite2.position.y = cloud_start_y
	darkness_layer.color.a = 0.0
	lightning_timer = randf_range(lightning_min_interval, lightning_max_interval)
	update_countdown_label()
	if Globals.timer_mode_on:
		countdown_label.show()
	else:
		countdown_label.hide()

func _process(delta: float) -> void:
	storm_progress = min((storm_timer.wait_time - storm_timer.time_left) / storm_timer.wait_time, 1.0)
	var current_cloud_speed = lerp(cloud_scroll_speed, cloud_max_speed, storm_progress)
	cloud_sprite1.position.x -= current_cloud_speed * delta
	cloud_sprite2.position.x -= current_cloud_speed * delta
	if cloud_sprite1.position.x < wrap_position:
		cloud_sprite1.position.x = reset_position
	if cloud_sprite2.position.x < wrap_position:
		cloud_sprite2.position.x = reset_position
	var current_cloud_y = lerp(cloud_start_y, cloud_end_y, storm_progress)
	cloud_sprite1.position.y = current_cloud_y 
	cloud_sprite2.position.y = current_cloud_y
	if storm_progress >= lightning_start_threshold:
		var lightning_progress = (storm_progress - lightning_start_threshold) / (1.0 - lightning_start_threshold)
		lightning_timer -= delta
		if lightning_timer <= 0:
			trigger_lightning_flash()
			var current_min_interval = lerp(lightning_min_interval, lightning_min_interval_end, lightning_progress)
			var current_max_interval = lerp(lightning_max_interval, lightning_max_interval_end, lightning_progress)
			lightning_timer = randf_range(current_min_interval, current_max_interval)
	var time_left = storm_timer.time_left
	var elapsed_time = storm_duration - time_left
	if elapsed_time > rain_start_time:
		var rain_progress = clamp((elapsed_time - rain_start_time) / (rain_max_intensity_time - rain_start_time), 0, 1)
		update_rain_intensity(rain_progress)
	update_storm_effects(delta)
	update_countdown_label()
	if storm_active:
		storm_sprite.position.y += storm_speed * delta
		if storm_sprite.position.y > get_viewport().get_visible_rect().size.y + 1000:
			storm_active = false
			storm_sprite.visible = false  # Hide the clouds once they are off-screen

func update_countdown_label() -> void:
	var time_left = storm_timer.time_left
	@warning_ignore("integer_division")
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	countdown_label.text = str(minutes) + ":" + str(seconds).pad_zeros(2)

func trigger_lightning_flash() -> void:
	$LightningSound.play()
	var flicker_count = randi_range(2, 4)
	for i in range(flicker_count):
		var delay = randi_range(50, 200) / 1000.0
		await get_tree().create_timer(delay).timeout
		flicker_lightning()

func flicker_lightning() -> void:
	$LightningFlash.color.a = 0.8
	var tween = create_tween()
	tween.tween_property($LightningFlash, "color:a", 0.0, 0.1)

func _on_rain_timer_timeout():
	rain_particles.emitting = true

func update_rain_intensity(rain_progress: float) -> void:
	var emission_amount = lerp(100, 500, rain_progress)
	var current_gravity_y = lerp(gravity_start_y, gravity_end_y, rain_progress)
	var current_gravity_x = lerp(gravity_start_x, gravity_end_x, rain_progress)
	var threshold = 100
	if abs(emission_amount - previous_emission_amount) > threshold or abs(current_gravity_x - previous_gravity_x) > threshold or abs(current_gravity_y - previous_gravity_y) > threshold:
		var process_material = rain_particles.process_material as ParticleProcessMaterial
		process_material.gravity = Vector3(current_gravity_x, current_gravity_y, 0)
		rain_particles.amount = emission_amount
		var gradient = GradientTexture2D.new()
		var gradient_data = Gradient.new()
		var start_color = Color("ffffff")
		var end_color = Color("ffffff")
		gradient_data.add_point(0.0, start_color)
		gradient_data.add_point(1.0, end_color)
		gradient.gradient = gradient_data
		process_material.color_ramp = gradient
		rain_particles.preprocess = 1.0
		previous_emission_amount = emission_amount
		previous_gravity_x = current_gravity_x
		previous_gravity_y = current_gravity_y
		print("updating rain")

func update_storm_effects(_delta: float) -> void:
	darkness_layer.color.a = storm_progress * darkness_max_opacity
	storm_music.volume_db = lerp(-8, -7, storm_progress)
	storm_audio.volume_db = lerp(-20, 5, storm_progress)
	rain_audio.volume_db = lerp(-25, 3, storm_progress)
	wind_audio.volume_db = lerp(-27, -1, storm_progress)

func trigger_storm_movement():
	storm_sprite.visible = true
	storm_active = true
	$StormClouds.hide()
	$StormClouds2.hide()
	if storm_sprite.position.y > get_viewport().get_visible_rect().size.y + 1000:
		storm_active = false
		storm_sprite.visible = false 

func _on_storm_timer_timeout():
	trigger_storm_movement()
	countdown_label.hide()
	Player.is_movement_enabled = false
	print("Round over")
	if Globals.player_inside:
		Globals.win_status = "made_it_inside"
		Player.hide()
		print("Made it inside")
		if Globals.shack_strength >= Globals.storm_strength:
			Globals.shack_survived = true
			print("Shack survived")
			if Globals.heat_points >= Globals.heat_needed:
				Globals.stayed_warm = true
				print("Stayed warm")
			else:
				Globals.froze_to_death = true
				await get_tree().create_timer(8).timeout
				Globals.win_status = "player_froze"
				$EndGameLabel.text = "You froze to death!"
				$EndGameLabel2.text = "Shack level: " + str(Globals.shack_strength) + "/" + str(Globals.storm_strength)
				$EndGameLabel3.text = "Heat level: " + str(Globals.heat_points) + "/" + str(Globals.heat_needed)
				$EndGameLabel4.text = "Food level: " + str(Globals.food_points) + "/" + str(Globals.food_needed)
				$EndGameLabel5.text = "Try storing more coal!"
				print("Froze")
			if Globals.food_points >= Globals.food_needed:
				Globals.enough_food = true
				print("Enough food")
			else:
				Globals.starved_to_death = true
				await get_tree().create_timer(8).timeout
				Globals.win_status = "player_starved"
				$EndGameLabel.text = "You starved to death!"
				$EndGameLabel2.text = "Shack level: " + str(Globals.shack_strength) + "/" + str(Globals.storm_strength)
				$EndGameLabel3.text = "Heat level: " + str(Globals.heat_points) + "/" + str(Globals.heat_needed)
				$EndGameLabel4.text = "Food level: " + str(Globals.food_points) + "/" + str(Globals.food_needed)
				$EndGameLabel5.text = "Try storing more food!"
				print("Starved")
		else:
			Globals.shack_destroyed = true
			await get_tree().create_timer(3).timeout
			Globals.win_status = "shack_destroyed"
			$EndGameLabel.text = "Your shack was destroyed!"
			$EndGameLabel2.text = "Shack level: " + str(Globals.shack_strength) + "/" + str(Globals.storm_strength)
			$EndGameLabel3.text = "Heat level: " + str(Globals.heat_points) + "/" + str(Globals.heat_needed)
			$EndGameLabel4.text = "Food level: " + str(Globals.food_points) + "/" + str(Globals.food_needed)
			$EndGameLabel5.text = "Try upgrading more!"
			print("Shack destroyed")
		if Globals.shack_survived and Globals.stayed_warm and Globals.enough_food:
			await get_tree().create_timer(8).timeout
			Globals.win_status = "player_won"
			$EndGameLabel.text = "You win!"
			$EndGameLabel2.text = "Shack level: " + str(Globals.shack_strength) + "/" + str(Globals.storm_strength)
			$EndGameLabel3.text = "Heat level: " + str(Globals.heat_points) + "/" + str(Globals.heat_needed)
			$EndGameLabel4.text = "Food level: " + str(Globals.food_points) + "/" + str(Globals.food_needed)
			$EndGameLabel5.text = "Great work!"
			print("You survived!")
	else:
		trigger_lightning_flash()
		Player.get_node("LightningSprite").visible = true
		Player.get_node("PlayerSprite").play("electrocution")
		print("Caught out in the storm")
		await get_tree().create_timer(1.5).timeout
		Player.get_node("PlayerSprite").stop()
		Player.get_node("LightningSprite").visible = false
		$EndGameLabel.text = "You got stuck out in the storm!"
		$EndGameLabel2.text = "Shack level: " + str(Globals.shack_strength) + "/" + str(Globals.storm_strength)
		$EndGameLabel3.text = "Heat level: " + str(Globals.heat_points) + "/" + str(Globals.heat_needed)
		$EndGameLabel4.text = "Food level: " + str(Globals.food_points) + "/" + str(Globals.food_needed)
		$EndGameLabel5.text = "Make sure you're inside when
		the storm starts. Try timer mode!"
	await get_tree().create_timer(6).timeout
	$EndGameLabel.show()
	$EndGameLabel2.show()
	$EndGameLabel3.show()
	$EndGameLabel4.show()
	$EndGameLabel5.show()
	$RestartButton.show()

func reset_storm() -> void:
	$EndGameLabel.text = ""
	$EndGameLabel2.text = ""
	$EndGameLabel3.text = ""
	$EndGameLabel4.text = ""
	$EndGameLabel5.text = ""
	$EndGameLabel.hide()
	$EndGameLabel2.hide()
	$EndGameLabel3.hide()
	$EndGameLabel4.hide()
	$EndGameLabel5.hide()
	$RestartButton.hide()
	$RestartButton.hide()
	storm_sprite.position = Vector2(2160, -760)
	$StormClouds.visible = true
	$StormClouds2.visible = true
	storm_progress = 0.0
	storm_timer.stop()
	storm_timer.start(storm_duration)
	$RainTimer.stop()
	$RainTimer.start()
	
	cloud_sprite1.position.y = cloud_start_y
	cloud_sprite2.position.y = cloud_start_y

	rain_particles.emitting = false
	previous_emission_amount = -1.0
	previous_gravity_x = -1.0
	previous_gravity_y = -1.0

	darkness_layer.color.a = 0.0

	storm_music.volume_db = -8
	storm_audio.volume_db = -20
	rain_audio.volume_db = -25
	wind_audio.volume_db = -27

	storm_music.stop()
	storm_music.play()
	storm_audio.stop()
	storm_audio.play()
	rain_audio.stop()
	rain_audio.play()
	wind_audio.stop()
	wind_audio.play()

	lightning_timer = randf_range(lightning_min_interval, lightning_max_interval)

	if Globals.timer_mode_on:
		countdown_label.show()
	else:
		countdown_label.hide()

	print("Storm reset complete.")

func _on_restart_button_pressed():
	SettingsLayer._on_restart_round_pressed()
