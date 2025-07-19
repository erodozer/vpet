extends Control

@onready var anim: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	if not GameState.lights_on:
		_toggle_lights(GameState.lights_on, true)

func _toggle_lights(lights_on, immediate = false):
	if lights_on:
		anim.play("lights_on")
	else:
		anim.play("lights_off")
	
	if immediate:
		anim.advance(INF)
	await anim.animation_finished
	
	GameState.lights_on = lights_on

func _on_ui_controls_action_pressed(action_type: String, item) -> void:
	match action_type:
		"light":
			_toggle_lights(!GameState.lights_on)
