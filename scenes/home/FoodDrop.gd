extends AnimatedSprite2D

var food: FoodResource
var left_bound
var right_bound

func drop(f: FoodResource):
	if f.unlock and not GameState.unlocks.get(f.unlock.flag, false):
		await get_tree().process_frame
		return false
		
	self.food = f
	self.sprite_frames = f.animation
	var tween = create_tween()
	play("default")
	material.set_shader_parameter("width", 1)

	var next_pos = randf_range(left_bound, right_bound)
	
	tween.tween_property(self, "position", Vector2(next_pos, 62), 2.0)\
		.from(Vector2(next_pos, -24))\
		.set_trans(Tween.TRANS_LINEAR)
	
	await tween.finished
	return true
	
func eat():
	material.set_shader_parameter("width", 0)
	play("eat")
	
	await self.animation_finished
	position = Vector2(-1000, -1000)

	GameState.stats = {
		"hungry": GameState.stats.hungry + food.hungry,
		"boredom": GameState.stats.boredom + food.boredom,
	}
	GameState.timers = {
		"eat": GameState.now() + food.cooldown
	}
	
	var counter = "food.%s" % food.name
	GameState.counters = {
		counter: GameState.counters.get(counter, 0) + 1
	}
