extends CanvasLayer

func _on_close_settings_pressed():
	hide()
	get_tree().paused = false

func _on_close_game_pressed():
	get_tree().paused = false
	get_tree().quit()
