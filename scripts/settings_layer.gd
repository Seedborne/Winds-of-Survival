extends CanvasLayer

func _on_close_settings_pressed():
	hide()
	get_tree().paused = false

func _on_restart_round_pressed():
	Globals.player_inside = false
	Player.update_animation()
	Player.is_movement_enabled = true
	Player.visible = true
	Player.current_stamina = Player.max_stamina
	Globals.reset_game_state()
	if Globals.current_zone == "ShackZone":
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/ShackZone.tscn")
	Storm.reset_storm()
	hide()
	get_tree().paused = false

func _on_tutorial_mode_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Globals.tutorial_mode_on = true
		print("Tutorial Mode On")
	else:
		Globals.tutorial_mode_on = false
		print("Tutorial Mode Off")

func _on_difficulty_easy_pressed():
	Globals.storm_strength = 80
	Globals.food_needed = 20
	Globals.heat_needed = 8
	Globals.difficulty = "easy"
	print("Switched to ", Globals.difficulty, " difficulty")
	$SettingsMenu/DifficultyEasy.disabled = true
	$SettingsMenu/DifficultyNormal.disabled = false
	$SettingsMenu/DifficultyHard.disabled = false


func _on_difficulty_normal_pressed():
	Globals.storm_strength = 100
	Globals.food_needed = 30
	Globals.heat_needed = 10
	Globals.difficulty = "normal"
	print("Switched to ", Globals.difficulty, " difficulty")
	$SettingsMenu/DifficultyNormal.disabled = true
	$SettingsMenu/DifficultyEasy.disabled = false
	$SettingsMenu/DifficultyHard.disabled = false

func _on_difficulty_hard_pressed():
	Globals.storm_strength = 150
	Globals.food_needed = 40
	Globals.heat_needed = 12
	Globals.difficulty = "hard"
	print("Switched to ", Globals.difficulty, " difficulty")
	$SettingsMenu/DifficultyHard.disabled = true
	$SettingsMenu/DifficultyEasy.disabled = false
	$SettingsMenu/DifficultyNormal.disabled = false

func _on_timer_mode_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Globals.timer_mode_on = true
		Storm.countdown_label.visible = true
		print("Timer Mode On")
	else:
		Globals.timer_mode_on = false
		Storm.countdown_label.visible = false
		print("Timer Mode Off")

func _on_close_game_pressed():
	get_tree().paused = false
	get_tree().quit()
