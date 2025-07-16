extends Node

const Rating = preload("../enum.gd").Rating
const HypeLevel = preload("../enum.gd").HypeLevel

var scratch_animations = []
@export var scratch_samples: Array[AudioStream] = []

@onready var dj: AnimatedSprite2D = get_node("%DJ")
@onready var pet = get_node("%Pet")
@onready var scratch_fx = get_node("%ScratchFx")

var bouncing = false

func _ready():
	pet.play("walk")
	
	for a in dj.sprite_frames.get_animation_names():
		if a.begins_with("scratch"):
			scratch_animations.append(a)
	
func _update_groove():
	if !dj.is_playing():
		if bouncing:
			dj.play("good")
		else:
			dj.play("default")
	
func _on_rhythm_play_note(rating: Rating, _combo: int) -> void:
	if rating == Rating.MISS:
		_update_groove()
		return
	
	pet.stop()
	pet.play("dance")
	pet.animation_looped.connect(
		func ():
			pet.play("walk"),
		CONNECT_ONE_SHOT
	)
	dj.stop()
	
	dj.play(scratch_animations.pick_random())
	scratch_fx.stream = scratch_samples.pick_random()
	scratch_fx.play()
	
	await dj.animation_finished
	_update_groove()

func _on_hype_level_updated(hype: HypeLevel) -> void:
	bouncing = hype == HypeLevel.PARTY
