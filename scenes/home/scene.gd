extends Node2D

const BATH_COOLDOWN = 120.0  # 2 minutes
const CURE_COOLDOWN = 1800.0 # 30 minute

@onready var pet = get_node("%ShopView/Pet")
@onready var food = get_node("%FoodDrop")
@onready var controls = get_node("%UIControls")

# barriers around twitch chat to prevent
# processing too many commands or simultaneous commands
var accepting_actions = true

func _on_TwitchIntegration_chat_command(action):
	if not accepting_actions:
		return
		
	match action:
		"lights off":
			_toggle_lights(false)
		"lights on":
			_toggle_lights(true)
		"food", "give food":
			var choice = (controls.menu.get_unlocked(controls.menu.food) as Array).pick_random()
			_drop_food(choice)
		"bath", "bathe", "wash":
			_bathe()
		"heal", "cure", "give medicine":
			_give_medicine()
		
func _on_UIControls_action_pressed(action_type, is_pressed, meta = null):
	if not accepting_actions:
		return
		
	match action_type:
		"light":
			_toggle_lights(is_pressed)
		"food":
			_drop_food(meta)
		"cure":
			_give_medicine()
		"bath":
			_bathe()
		"game":
			_game(meta)
		"health":
			_show_stats()
		"gift":
			SceneManager.change_scene("unlockshop")
	
func _ready():
	var left = get_node("%LeftBound").position.x
	var right = get_node("%RightBound").position.x
	pet.left_bound = left
	pet.right_bound = right
	food.left_bound = left
	food.right_bound = right
	
	# backfill processing for while the player was away
	# var catch_up = clamp((GameState.now() - GameState.timers.update) / float(GameState.UPDATE_FREQ), 0, 300.0)
	# for _i in range(catch_up):
	# 	GameState.execute_turn()
		
	%WashScene/Pet/Sprite2D.play("bath")
	
	Twitch.command.connect(_on_twitch_command)
	NoClick.hide()
	
func _setup(_params):
	pet.pause = false
	if not GameState.lights_on:
		_toggle_lights(GameState.lights_on)
	
func _show_stats():
	accepting_actions = false
	# pause processing while bathing
	NoClick.visible = true

	var ui = get_node("UIControls")
	var camera = pet.get_node("FollowCamera") as Camera2D
	
	ui.show_submenu("stats")
	var panel = get_node("%StatusPanel")
	panel.current_tab = 0
	var tween = create_tween()
	tween.parallel().tween_property(panel, "position:x", 64.0, 0.3)
	tween.parallel().tween_property(camera, "offset:x", 48.0, 0.3)
	tween.parallel().tween_property(camera, "limit_right", 208, 0.5)
	tween.parallel().tween_property(camera, "limit_left", -48, 0.5)
	await tween.finished
	NoClick.visible = false
	
	while true:
		var action = await ui.action_pressed
		if action[0] == "back":
			break
		elif action[0] == "details":
			panel.toggle_details()
		elif action[0] == "counters":
			panel.toggle_counters()
	
	# pause processing while bathing
	NoClick.visible = true

	tween = create_tween()
	tween.parallel().tween_property(panel, "position:x", 160.0, 0.3)
	tween.parallel().tween_property(camera, "offset:x", 0.0, 0.3)
	tween.parallel().tween_property(camera, "limit_right", 160, 0.3)
	tween.parallel().tween_property(camera, "limit_left", 0, 0.3)
	await tween.finished
	NoClick.visible = false
	ui.show_menu()
	accepting_actions = true
	
func _toggle_lights(lights_on):
	accepting_actions = false
	# pause processing while bathing
	NoClick.visible = true
	
	if lights_on:
		get_node("%ShopView/Environment/AnimationPlayer").play("lights_on")
	else:
		get_node("%ShopView/Environment/AnimationPlayer").play("lights_off")
	
	await get_node("%ShopView/Environment/AnimationPlayer").animation_finished
	# pause processing while bathing
	NoClick.visible = false

	GameState.lights_on = lights_on
	accepting_actions = true

func _game(game):
	if not GameState.can_act(GameState.GameActions.Play):
		return
		
	accepting_actions = false
	
	if not game:
		game = controls.menu.get_default(controls.menu.games)
		if len(controls.menu.get_unlocked(controls.menu.games)) > 1:
			controls.show_submenu("game")
			var result = await controls.action_pressed
			var action = result[2]
			
			if action == null:
				controls.show_menu()
				accepting_actions = true
				return
			game = action
			controls.show_menu("Game")
			
	# pause processing while lookin for food
	NoClick.visible = true
	
	var counter = "game.%s" % game.game
	GameState.counters = {
		counter: GameState.counters.get(counter, 0) + 1
	}

	SceneManager.change_scene("game_" + game.game)
	
	NoClick.visible = false
	accepting_actions = true

func _bathe():
	if not GameState.can_act(GameState.GameActions.Bathe):
		return
	
	accepting_actions = false
	# pause processing while bathing
	NoClick.visible = true
	
	pet.pause = true
	
	var wash = get_node("WashScene")
	var wash_bg = wash.get_node("Background") as AnimatedSprite2D
	var scenes = wash_bg.sprite_frames.get_animation_names()
	wash_bg.play(scenes[randi() % len(scenes)])
	
	await get_node("Transition").fade_in()
	wash.visible = true
	get_node("ShopView").visible = false
	await get_node("Transition").fade_out()

	# better soap completely cleans the fox
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
	await get_node("Transition").fade_in()
	wash.visible = false
	get_node("ShopView").visible = true
	await get_node("Transition").fade_out()
	
	# pause processing while lookin for food
	NoClick.visible = false
	pet.pause = false
	accepting_actions = true
	
func _give_medicine():
	if not GameState.can_act(GameState.GameActions.Medicine):
		return
		
	accepting_actions = false
	GameState.stats = {
		"sick": 0.0
	}
	# medicine should not be allowed frequent usage
	# to encourage you to properly take care of the fox
	GameState.timers = {
		"medicine": GameState.now() + CURE_COOLDOWN
	}
	accepting_actions = true
	
func _drop_food(food_type = null):
	if not GameState.can_act(GameState.GameActions.Eat):
		return
		
	accepting_actions = false
	
	if not food_type:
		food_type = controls.menu.get_default(controls.menu.food)
		if len(controls.menu.get_unlocked(controls.menu.food)) > 1:
			controls.show_submenu("food")
			var result = await controls.action_pressed
			var action = result[2]
			
			if action == null:
				controls.show_menu("Food")
				accepting_actions = true
				return
			food_type = action
			controls.show_menu("Food")
			
	# pause processing while lookin for food
	NoClick.visible = true
	
	pet.pause = true
	var can_drop = await food.drop(food_type)
	if can_drop:
		await pet.move_to(food.position, 30.0)
		pet.eat()
		await food.eat()
	pet.pause = false
	
	NoClick.visible = false
	accepting_actions = true

func _process(_delta):
	if GameState.now() > GameState.timers.update:
		GameState.execute_turn()
	
	if GameState.is_dead():
		GameState.reset()
		set_process(false)
		SceneManager.change_scene("home")

func _on_twitch_command(type, event):
	if type != Tmi.EventType.CHAT_MESSAGE:
		return
		
	if not event.raw_message.begins_with("!pet"):
		return 
	
	var command = event.raw_message.substr(4).strip_edges()
	_on_TwitchIntegration_chat_command(command)
