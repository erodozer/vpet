extends TextureRect

func _enter_tree() -> void:
	var m: ShaderMaterial = self.material
	m.set_shader_parameter(
		"speed", ProjectSettings.get_setting_with_override("application/vpet/style_bg_scroll")
	)
