extends Node2D

const CURE_COOLDOWN = 1800.0 # 30 minute

@onready var pet = get_node("%Pet")
@onready var controls = get_node("%UIControls")

func _on_UIControls_action_pressed(action_type, meta = null):
	match action_type:
		"cure":
			_give_medicine()
		"game":
			_game(meta)
		"gift":
			SceneManager.change_scene("unlockshop")
	
func _setup(_params):
	pet.pause = false

func _game(game):
	var counter = "game.%s" % game.game
	GameState.counters = {
		counter: GameState.counters.get(counter, 0) + 1
	}

	SceneManager.change_scene("game_" + game.game)
	
func _give_medicine():
	if not GameState.can_act(GameState.GameActions.Medicine):
		return
		
	GameState.stats = {
		"sick": 0.0
	}
	# medicine should not be allowed frequent usage
	# to encourage you to properly take care of the fox
	GameState.timers = {
		"medicine": GameState.now() + CURE_COOLDOWN
	}

func _process(_delta):
	if GameState.now() > GameState.timers.update:
		GameState.execute_turn()
	
	if GameState.is_dead():
		GameState.reset()
		set_process(false)
		SceneManager.change_scene("home")
