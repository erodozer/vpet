extends Resource
class_name FoodResource

@export_range(0, 250) var hungry = 0.0
@export_range(-100, 100) var boredom = 0.0
@export_range(0.1, 5.0) var cooldown = 1.0
@export var unlock: ShopResource
@export var icon: Texture2D
@export var animation: SpriteFrames

var name : String :
	get():
		if self.resource_name != "":
			return self.resource_name
		return self.resource_path.get_file().split(".")[0]
	
