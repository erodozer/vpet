extends TabContainer

var show_details = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.connect("stats_changed", Callable(self, "_update_stats"))

func toggle_details():
	if current_tab == 1:
		current_tab = 0
	else:
		current_tab = 1

func toggle_counters():
	if current_tab == 2:
		current_tab = 0
	else:
		current_tab = 2

func _update_stats(stats):
	
	# determine mood	
	var mood = "Happy"
	if stats.hungry < 50.0:
		mood = "Hungry"
	if stats.weight < 20.0:
		mood = "Malnurished"
	if stats.weight > 80.0:
		mood = "Overweight"
	if stats.boredom > 70.0:
		mood = "Bored"
	if stats.dirty > 50.0:
		mood = "Stinky"
	if stats.tired > 70.0:
		mood = "Tired"
	if stats.sick > 75.0:
		mood = "Sick"
	
	get_node("%Mood").text = mood

	get_node("%Weight").text = "%.1f %s" % [
		lerp(
			ProjectSettings.get_setting_with_override("application/vpet/weight_range").x,
			ProjectSettings.get_setting_with_override("application/vpet/weight_range").y,
			clamp(stats.weight / 100.0, 0.0, 1.0)
		),
		ProjectSettings.get_setting_with_override("application/vpet/weight_unit"),
	]
		
	get_node("%LifeMeter").value = inverse_lerp(0.0, 100.0, stats.hungry) * 5.0
	get_node("%HappyMeter").value = inverse_lerp(0.0, 10.0, GameState.honey_score()) * 5.0
	get_node("%Age").text = "%02dd %02dh %02dm" % [
		int(stats.age / 86400.0), # days
		int(stats.age / 3600.0) % 24, # hours
		int(stats.age / 60.0) % 60, # minutes
	]

	get_node("%HungryValue").text = "%.1f" % stats.hungry
	get_node("%BoredomValue").text = "%.1f" % stats.boredom
	get_node("%TirednessValue").text = "%.1f" % stats.tired
	get_node("%SickValue").text = "%.1f" % stats.sick
	get_node("%DirtyValue").text = "%.1f" % stats.dirty
