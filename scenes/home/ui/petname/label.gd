extends Label

func _ready():
	text = ProjectSettings.get_setting_with_override("application/vpet/name")
