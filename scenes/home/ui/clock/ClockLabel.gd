extends Label

func _ready():
	update_text()

func update_text():
	match GameState.time_scale:
		GameState.TimeMode.Slow:
			text = "Mode: SLOW"
		GameState.TimeMode.Fast:
			text = "Mode: FAST"
			
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		match GameState.time_scale:
			GameState.TimeMode.Slow:
				GameState.time_scale = GameState.TimeMode.Fast
			GameState.TimeMode.Fast:
				GameState.time_scale = GameState.TimeMode.Slow
		update_text()
