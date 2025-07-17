extends MarginContainer

const HYPE_SCALE = Vector2(0.0, 110.0)
const Rating = preload("../enum.gd").Rating
const HypeLevel = preload("../enum.gd").HypeLevel

@onready var meter: Range = get_node("%ProgressBar")
@onready var cheers = get_node("%Cheers")

var hype: float = 30 :
	set(v):
		hype = v
		meter.value = v
		if hype > 70:
			hype_level.emit(HypeLevel.PARTY)
			cheers.visible = true
		else:
			hype_level.emit(HypeLevel.GROOVE)
			cheers.visible = false
		
signal hype_level(hype: HypeLevel)

func _on_rhythm_play_note(rating: Variant, combo: int) -> void:
	var diff: int
	match rating:
		Rating.BAD:
			diff = -5
		Rating.OK:
			diff = 1
		Rating.GOOD:
			diff = 2
		Rating.GREAT:
			diff = 3
		_:
			diff = -8
			
	hype = clampf(hype + diff, HYPE_SCALE.x, HYPE_SCALE.y)
	
