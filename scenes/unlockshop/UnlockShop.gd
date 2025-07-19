extends Control

@export var menu: ResourceMenu

var selected

func _ready():
	for i in menu.shop:
		var btn = preload("./ItemButton.tscn").instantiate()
		btn.set_meta("item", i)
		btn.focus_entered.connect(select_item.bind(i))
		btn.focus_entered.connect(btn.get_node("AudioStreamPlayer").play)
		get_node("%Unlockables").add_child(btn)
		btn.get_node("%Label").text = i.display_name
		btn.get_node("%Price").text = "%d" % i.cost if not GameState.unlocks.get(i.flag, false) else "SOLD"
	
	var first = get_node("%Unlockables").get_child(0)
	first.grab_focus()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_Back_pressed()
		accept_event()	
	if event.is_action_pressed("ui_select"):
		_on_BuyButton_pressed()
		accept_event()
	
func select_item(item):
	get_node("%ItemDescription").text = item.description
	get_node("%BuyButton").disabled = item.cost > GameState.stats.honey or GameState.unlocks.get(item.flag, false)
	selected = item
	create_tween().tween_property(
		get_node("%ItemDescription"),
		"visible_ratio",
		1.0,
		0.25
	).from(0.0)

func _on_BuyButton_pressed():
	get_node("%BuyButton/AudioStreamPlayer").play()
	var item = selected
	if item.cost > GameState.stats.honey:
		return
		
	GameState.stats = {
		"honey": GameState.stats.honey - item.cost
	}
	
	match item.flag:
		"pet.feed":
			GameState.stats = {
				"hungry": 100
			}
		"pet.overfeed":
			GameState.stats = {
				"hungry": 250
			}
		"reset.cooldowns":
			GameState.reset(true, false, false)
		"reset.game":
			GameState.reset(true, true, true)
			SceneManager.change_scene("home")
		_:
			GameState.unlocks = {
				item.flag: true,
			}
			
	select_item(item)
	GameState.save_data()
	
	for btn in get_node("%Unlockables").get_children():
		var i = btn.get_meta("item")
		btn.get_node("%Price").text = "%d" % i.cost if not GameState.unlocks.get(i.flag, false) else "SOLD"

func _on_Back_pressed():
	SceneManager.change_scene("home")
