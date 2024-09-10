extends Camera2D

func _ready() -> void:
	pass

func _process(_delta):
	if Globals.current_zone == "ShackZone":
		limit_left = 0
		limit_right = 1150
		limit_top = -475
		limit_bottom = 1425
	elif Globals.current_zone == "ForestZone":
		limit_left = 0
		limit_right = 4800
		limit_top = -2550
		limit_bottom = 650
	elif Globals.current_zone == "QuarryZone":
		limit_left = 0
		limit_right = 4800
		limit_top = -2550
		limit_bottom = 650
	elif Globals.current_zone == "AirplaneZone":
		limit_left = 0
		limit_right = 4800
		limit_top = -2550
		limit_bottom = 650
