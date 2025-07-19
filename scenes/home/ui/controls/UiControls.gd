extends TmiEventQueue

const gdsh = preload("res://addons/godash/godash.gd")
const Pet = preload("res://pet/Pet.gd")

signal action_pressed(action_type: String, item)
signal submenu_opened(menu: String)
signal submenu_closed(menu: String)

@export var pet: Pet
@export var menu: ResourceMenu

var active_menu: String

# Called when the node enters the scene tree for the first time.
func _ready():
	tmi = Twitch
	super._ready()
	
	# add food options dynamically
	for food in menu.food:
		var button = preload("../button/SimpleButton.tscn").instantiate()
		button.get_node("icon_on").texture = food.icon
		button.submenu = "food"
		button.unlocked = true if food.unlock == null else GameState.unlocks.get(food.unlock.flag, false)
		button.visible = false
		button.item = food
		get_node("%Controls").add_child(button)
		
	# add game options dynamically
	for game in menu.games:
		if game == null:
			continue
		var button = preload("../button/SimpleButton.tscn").instantiate()
		button.get_node("icon_on").texture = game.icon
		button.submenu = "game"
		button.unlocked = true if game.unlock == null else GameState.unlocks.get(game.unlock.flag, false)
		button.visible = false
		button.item = game
		get_node("%Controls").add_child(button)
	
	for button in get_node("%Controls").get_children():
		button.pressed.connect(_on_button_press.bind(button))
	
	get_node("%Controls/Light").button_pressed = GameState.lights_on
	get_node("%Controls/Food").grab_focus()
	
	if menu.counters.is_empty():
		get_node("%Controls/Counters").queue_free()

func show_submenu(submenu):
	for button in get_node("%Controls").get_children():
		button.visible = button.submenu == submenu and button.unlocked
		if button.is_cancel():
			button.visible = true
			button.grab_focus()
	active_menu = submenu
	submenu_opened.emit(submenu)
	
func show_menu():
	for button in get_node("%Controls").get_children():
		button.visible = button.submenu == "None"
		if button.name.to_lower() == active_menu:
			button.grab_focus()
		if button.is_cancel():
			button.visible = false
	var prev_menu = active_menu
	active_menu = ""
	submenu_closed.emit(prev_menu)

func _on_button_press(button):
	# do not allow actions when pet is paused
	if pet.pause:
		return
	
	if button.is_entrypoint():
		var submenu = button.action
		var submenu_items: Array
		if submenu == "food":
			submenu_items = menu.food
		elif submenu == "game":
			submenu_items = menu.games
		
		if submenu == "stats" or len(menu.get_unlocked(submenu_items)) > 1:
			show_submenu(submenu)
			return
		else:
			var item = menu.get_default(submenu_items)
			action_pressed.emit(
				submenu,
				item
			)
			return
			
	if button.is_cancel():
		show_menu()
		return
	
	action_pressed.emit(
		button.action,
		button.item if button.item != null else button.name.to_lower()
	)
	if button.close_on_use:
		show_menu()

#region TWITCH INTEGRATION

func accept_command(type, event) -> bool:
	return type == Tmi.EventType.CHAT_MESSAGE and event.raw_message.begins_with("!pet")

func process_event(type, event):
	# prevent processing too many commands or simultaneous commands
	if pet.pause:
		return
		
	var command = event.raw_message.substr(4).strip_edges()
	
	match command:
		"lights off":
			action_pressed.emit("lights", false)
		"lights on":
			action_pressed.emit("lights", true)
		"food", "give food":
			if not GameState.can_act(GameState.GameActions.Eat):
				return
			var choice = (menu.get_unlocked(menu.food) as Array).pick_random()
			action_pressed.emit("food", choice)
		"bath", "bathe", "wash":
			if not GameState.can_act(GameState.GameActions.Bathe):
				return
			action_pressed.emit("bath")
		"heal", "cure", "give medicine":
			if not GameState.can_act(GameState.GameActions.Medicine):
				return
			action_pressed.emit("medicine")
		
#endregion
