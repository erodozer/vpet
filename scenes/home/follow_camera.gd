extends Camera2D


func _on_ui_controls_submenu_opened(menu: String) -> void:
	if menu == "stats":
		var tween = create_tween()
		tween.parallel().tween_property(self, "offset:x", 48.0, 0.3)
		tween.parallel().tween_property(self, "limit_right", 208, 0.5)
		tween.parallel().tween_property(self, "limit_left", -48, 0.5)
		
func _on_ui_controls_submenu_closed(menu: String) -> void:
	if menu == "stats":
		var tween = create_tween()
		tween = create_tween()
		tween.parallel().tween_property(self, "offset:x", 0.0, 0.3)
		tween.parallel().tween_property(self, "limit_right", 160, 0.3)
		tween.parallel().tween_property(self, "limit_left", 0, 0.3)
