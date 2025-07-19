extends Button

@onready var border_tex: AnimatedSprite2D = get_node("border")
@onready var off_icon = get_node("icon_off")
@onready var on_icon = get_node("icon_on")
@onready var tick = get_node("AudioStreamPlayer")

@export_enum("None", GameState.GameActions.Eat, GameState.GameActions.Bathe, GameState.GameActions.Play, GameState.GameActions.Medicine) var bind_to_timer = "None"
@export_enum("None", "food", "game", "stats") var submenu = "None"
@export var close_on_use: bool = true
@export var unlocked: bool = true
@export var item: Resource = null

var action: String :
	get():
		return submenu if submenu != "None" else name.to_lower()

func _ready():
	connect("focus_entered", Callable(self, "_on_focus_entered"))
	connect("focus_exited", Callable(self, "_on_focus_exited"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
func is_entrypoint():
	return self.name.to_lower() in ["food", "game", "stats"]

func is_cancel():
	return self.name.to_lower() == "back"
	
func disable_action(state):
	off_icon.visible = state
	on_icon.visible = not state
	mouse_default_cursor_shape = CURSOR_ARROW if state else CURSOR_POINTING_HAND
	if has_focus() and state:
		var next = find_valid_focus_neighbor(SIDE_RIGHT)
		if not next:
			next = find_valid_focus_neighbor(SIDE_LEFT)
		if next:
			next.grab_focus()
	focus_mode = FOCUS_NONE if state else FOCUS_ALL
	set_disabled(state)
	
func _toggled(t):
	if not is_inside_tree():
		return
	
	off_icon.visible = not t
	on_icon.visible = t

func _on_mouse_entered():
	if not disabled:
		grab_focus()

func _on_focus_entered():
	border_tex.play("on")
	tick.play()
	show_behind_parent = false
	
func _on_focus_exited():
	border_tex.play("off")
	await border_tex.animation_finished
	show_behind_parent = true

func _process(_delta):
	if bind_to_timer != "None":
		disable_action(not GameState.can_act(bind_to_timer) && unlocked)
