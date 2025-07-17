extends Resource
class_name ResourceMenu

@export var food: Array[FoodResource] = []
@export var games: Array[GameResource] = []
@export var shop: Array[ShopResource] = []
@export var counters: Array[String] = []

func get_default(items: Array):
	return items[0]
	
func get_unlocked(items: Array):
	var u = []
	for i in items:
		if i.unlock == null or GameState.unlocks.get(i.unlock.flag, false):
			u.append(i)
	return u
	
