extends RichTextLabel

const Rating = preload("../enum.gd").Rating

func _on_play_note(rating: Rating) -> void:
	match rating:
		Rating.MISS:
			text = "[color=grey]MISS[/color]"
		Rating.BAD:
			text = "[color=purple]BAD[/color]"
		Rating.OK:
			text = "[color=pink]OK[/color]"
		Rating.GOOD:
			text = "[color=green]GOOD[/color]"
		_:
			text = "[rainbow]GREAT[/rainbow]"
			
	var t = create_tween()
	t.tween_property(
		self, "position:y", -8, 0.15
	).from(0)
	t.parallel().tween_property(
		self, "modulate", Color.WHITE, 0.1
	).from(Color.TRANSPARENT)
	t.tween_property(
		self, "position:y", 0, 0.15
	).set_delay(0.15)
	t.parallel().tween_property(
		self, "modulate", Color.TRANSPARENT, 0.15
	)
