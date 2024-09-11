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
		limit_right = 3360
		limit_top = -1750
		limit_bottom = 450
	elif Globals.current_zone == "QuarryZone":
		limit_left = 0
		limit_right = 3360
		limit_top = -1750
		limit_bottom = 450
	elif Globals.current_zone == "AirplaneZone":
		limit_left = 0
		limit_right = 3360
		limit_top = -1750
		limit_bottom = 450
