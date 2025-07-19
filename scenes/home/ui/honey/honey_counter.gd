extends PanelContainer

@onready var counter = get_node("%Amount")

var money: int = 0 :
	set(v):
		if counter:
			counter.text = "%0d" % int(v)
		money = v

func _ready():
	GameState.stats_changed.connect(_update_stats)
	_update_stats(GameState.stats, true)
	
func _update_stats(stats, immediate=false):
	if not immediate:
		create_tween().tween_property(
			self, "money", int(stats.honey), 0.3
		)
	else:
		self.money = stats.honey
