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

var lightning_timer: float = 0.0
var storm_progress: float = 0.0

var cloud_sprite1: Sprite2D
var cloud_sprite2: Sprite2D
var darkness_layer: ColorRect
var storm_music: AudioStreamPlayer
var storm_audio: AudioStreamPlayer
var rain_audio: AudioStreamPlayer
var wind_audio: AudioStreamPlayer

func _ready() -> void:
	cloud_sprite1 = $StormClouds
	cloud_sprite2 = $StormClouds2
	darkness_layer = $StormDarkness
	storm_music = $StormMusic
	storm_audio = $StormAudio
	rain_audio = $RainAudio
	wind_audio = $WindAudio
	storm_music.volume_db = 7
	storm_audio.volume_db = -5
	rain_audio.volume_db = -10
	wind_audio.volume_db = -12
	cloud_sprite1.position.y = cloud_start_y
	cloud_sprite2.position.y = cloud_start_y
	darkness_layer.color.a = 0.0
	lightning_timer = randf_range(lightning_min_interval, lightning_max_interval)

func _process(delta: float) -> void:
	var storm_timer = $StormTimer
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
			var current_min_interval = lerp(lightning_min_interval, lightning_min_interval_end, lightning_progress)
			var current_max_interval = lerp(lightning_max_interval, lightning_max_interval_end, lightning_progress)
			lightning_timer = randf_range(current_min_interval, current_max_interval)
	update_storm_effects(delta)

func update_storm_effects(_delta: float) -> void:
	darkness_layer.color.a = storm_progress * darkness_max_opacity
	storm_music.volume_db = lerp(7, 8, storm_progress)
	storm_audio.volume_db = lerp(-5, 20, storm_progress)
	rain_audio.volume_db = lerp(-10, 18, storm_progress)
	wind_audio.volume_db = lerp(-12, 14, storm_progress)

func _on_storm_timer_timeout():
	print("Round over")
