extends Resource
class_name GachaCardResource

var id: String : get = _get_id
var image: Texture2D : get = _get_resource_image
@export_range(1, 500) var price: int = 250

func _get_id() -> String:
	if self.resource_name:
		return self.resource_name
	return self.resource_path.get_file().get_basename()

func _get_resource_image() -> Texture2D:
	var path = self.resource_path
	var tex = load(path.get_basename() + ".png")
	if not tex:
		return Texture2D.new()
	return tex
