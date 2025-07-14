extends CanvasLayer

const gdsh = preload("res://addons/godash/godash.gd")

signal action_pressed(action_type, is_pressed, item)

@export var menu: ResourceMenu = null
@onready var clock = get_node("%Clock")
@onready var label = get_node("%PetName")
@onready var clock_label = get_node("%CurrentTime")

# Called when the node enters the scene tree for the first time.
func _ready():
	
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
	
	clock.pressed.connect(_on_clock_toggled)
	GameState.stats_changed.connect(_update_stats)
	%Controls/Light.button_pressed = GameState.lights_on
	
	%Controls/Food.grab_focus()
	
	set_hint_text("")

func show_submenu(submenu):
	for button in get_node("%Controls").get_children():
		button.visible = button.submenu == submenu and button.unlocked
		
	get_node("%Controls/Back").visible = true
	get_node("%Controls/Back").grab_focus()
	
func show_menu(submenu = "Food"):
	for button in get_node("%Controls").get_children():
		button.visible = button.submenu == "None"
	get_node("%Controls/Back").visible = false
	get_node("%Controls/" + submenu).grab_focus()

func _on_button_press(button):
	action_pressed.emit(
		button.name.to_lower(),
		button.button_pressed,
		button.item
	)

func _on_clock_toggled():
	await get_tree().process_frame # wait a frame
	var pressed = clock.button_pressed
	label.visible = not pressed
	clock_label.visible = pressed
	
func set_hint_text(text):
	if not text:
		print(ProjectSettings.get_setting_with_override("application/vpet/name"))
		label.text = ProjectSettings.get_setting_with_override("application/vpet/name")
	else:
		label.text = text

func _update_stats(stats):
	get_node("%HoneyCounter").text = "%0d" % int(stats.honey)
