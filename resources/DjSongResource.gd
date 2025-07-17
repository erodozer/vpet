extends Resource
class_name DJSongResource

@export var title: String
@export var audio: AudioStreamMP3
@export var start_offset: float = 0.0
@export_range(40, 400) var bpm = 100

var duration : float :
	get():
		return audio.get_length()
