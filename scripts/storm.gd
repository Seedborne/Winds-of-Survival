extends CanvasLayer

@export var cloud_scroll_speed: float = 25.0
@export var cloud_max_speed: float = 100.0
@export var wrap_position: float = -1200
@export var reset_position: float = 3170
@export var cloud_start_y: float = -100.0
@export var cloud_end_y: float = 100.0
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
var countdown_label: Label
var storm_timer = Timer

var cloud_sprite1: Sprite2D
var cloud_sprite2: Sprite2D
var darkness_layer: ColorRect
var storm_music: AudioStreamPlayer
var storm_audio: AudioStreamPlayer
var rain_audio: AudioStreamPlayer
var wind_audio: AudioStreamPlayer
var rain_particles: GPUParticles2D
var previous_emission_amount: float = -1.0
var previous_gravity_x: float = -1.0
var previous_gravity_y: float = -1.0

func _ready() -> void:
	storm_timer = $StormTimer
	countdown_label = $StormCountdown
	cloud_sprite1 = $StormClouds
	cloud_sprite2 = $StormClouds2
	darkness_layer = $StormDarkness
	storm_music = $StormMusic
	storm_audio = $StormAudio
	rain_audio = $RainAudio
	wind_audio = $WindAudio
	rain_particles = $RainParticles
	rain_particles.emitting = false
	storm_music.volume_db = 7
	storm_audio.volume_db = -5
	rain_audio.volume_db = -10
	wind_audio.volume_db = -12
	cloud_sprite1.position.y = cloud_start_y
	cloud_sprite2.position.y = cloud_start_y
	darkness_layer.color.a = 0.0
	lightning_timer = randf_range(lightning_min_interval, lightning_max_interval)
	update_countdown_label()

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
			$LightningSound.play()
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

func update_countdown_label() -> void:
	var time_left = storm_timer.time_left
	@warning_ignore("integer_division")
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	countdown_label.text = str(minutes) + ":" + str(seconds).pad_zeros(2)

func trigger_lightning_flash() -> void:
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
	storm_music.volume_db = lerp(7, 8, storm_progress)
	storm_audio.volume_db = lerp(-5, 20, storm_progress)
	rain_audio.volume_db = lerp(-10, 18, storm_progress)
	wind_audio.volume_db = lerp(-12, 14, storm_progress)

func _on_storm_timer_timeout():
	countdown_label.hide()
	print("Round over")
