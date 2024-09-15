extends Node2D

func _ready():
	pass

func _process(_delta):
	pass

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/ShackZone.tscn")

func _on_tutorial_mode_pressed(button_pressed: bool) -> void:
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
	$DifficultyEasy.disabled = true
	$DifficultyNormal.disabled = false
	$DifficultyHard.disabled = false


func _on_difficulty_normal_pressed():
	Globals.storm_strength = 100
	Globals.food_needed = 30
	Globals.heat_needed = 10
	Globals.difficulty = "normal"
	print("Switched to ", Globals.difficulty, " difficulty")
	$DifficultyNormal.disabled = true
	$DifficultyEasy.disabled = false
	$DifficultyHard.disabled = false

func _on_difficulty_hard_pressed():
	Globals.storm_strength = 150
	Globals.food_needed = 40
	Globals.heat_needed = 12
	Globals.difficulty = "hard"
	print("Switched to ", Globals.difficulty, " difficulty")
	$DifficultyHard.disabled = true
	$DifficultyEasy.disabled = false
	$DifficultyNormal.disabled = false

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
	get_tree().quit()
