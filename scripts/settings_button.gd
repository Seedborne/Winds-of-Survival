extends Button

func _input(_event):
	if Input.is_action_pressed("settings"):
		UI._on_settings_button_pressed()
