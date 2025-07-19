extends Node2D

const BATH_COOLDOWN = 120.0  # 2 minutes

const Pet = preload("res://pet/Pet.gd")

@export var pet: Pet

func _ready() -> void:
	# different pet, render only no state
	get_node("View/Pet").play("bath")

func _on_ui_controls_action_pressed(action_type: String, item: Variant) -> void:
	if action_type != "bath":
		return
	
	pet.pause = true
	
	var wash_bg = get_node("View/Background") as AnimatedSprite2D
	var scenes = wash_bg.sprite_frames.get_animation_names()
	wash_bg.play(scenes[randi() % len(scenes)])
	
	get_node("Transition/AnimationPlayer").play("fade_in")
	await get_node("Transition/AnimationPlayer").animation_finished
	get_node("View").visible = true
	get_node("Transition/AnimationPlayer").play("fade_out")
	await get_node("Transition/AnimationPlayer").animation_finished

	# better soap completely cleans the pet
	if GameState.unlocks.get("bath.soap", false):
		GameState.stats = {
			"dirty": 0.0,
		}
	else:
		GameState.stats = {
			"dirty": GameState.stats.dirty - 40,
		}
	
	GameState.timers = {
		GameState.GameActions.Bathe: GameState.now() + BATH_COOLDOWN
	}
	var counter = "bathed"
	GameState.counters = {
		counter: GameState.counters.get(counter, 0) + 1
	}

	await get_tree().create_timer(3.0).timeout
	
	get_node("Transition/AnimationPlayer").play("fade_in")
	await get_node("Transition/AnimationPlayer").animation_finished
	get_node("View").visible = false
	get_node("Transition/AnimationPlayer").play("fade_out")
	await get_node("Transition/AnimationPlayer").animation_finished
	
	pet.pause = false
