extends AnimatedSprite2D

const Pet = preload("res://pet/Pet.gd")

@export var pet: Pet

var food: FoodResource
var left_bound
var right_bound

func drop(f: FoodResource):
	pet.pause = true
	
	self.food = f
	self.sprite_frames = f.animation
	var tween = create_tween()
	play("default")
	material.set_shader_parameter("width", 1)

	var bounds = Vector2(
		(get_parent() as Control).get_rect().size.x / -2 + (get_parent() as Control).position.x,
		(get_parent() as Control).get_rect().size.x / 2 + (get_parent() as Control).position.x
	)
	var next_pos = randf_range(bounds.x, bounds.y)
	
	tween.tween_property(self, "position", Vector2(next_pos, -12), 2.0)\
		.from(Vector2(next_pos, -94))\
		.set_trans(Tween.TRANS_LINEAR)
	
	await tween.finished
	
	await pet.move_to(self.position, 30.0)
	
	pet.eat()
	material.set_shader_parameter("width", 0)
	play("eat")
	
	await self.animation_finished
	position = Vector2(-1000, -1000)

	GameState.stats = {
		"hungry": GameState.stats.hungry + food.hungry,
		"boredom": GameState.stats.boredom + food.boredom,
	}
	GameState.timers = {
		"eat": GameState.now() + (food.cooldown * 60.0)
	}
	
	var counter = "food.%s" % food.name
	GameState.counters = {
		counter: GameState.counters.get(counter, 0) + 1
	}
	
	pet.pause = false

func _on_ui_controls_action_pressed(action_type: String, item = null) -> void:
	match action_type:
		"food":
			drop(item as Resource)
