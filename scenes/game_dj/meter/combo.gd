extends RichTextLabel

const Rating = preload("../enum.gd").Rating

@onready var anim = get_node("AnimationPlayer")

func _on_rhythm_play_note(rating: Rating, combo: int) -> void:
	if combo > 10:
		if anim.assigned_animation != "show":
			anim.play("show")
		text = "[rainbow]%d combo[/rainbow]" % combo
	elif combo == 0 and anim.assigned_animation == "show":
		anim.play("hide")
