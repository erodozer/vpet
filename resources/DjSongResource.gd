extends Resource
class_name DJSongResource

@export var audio: AudioStreamMP3
@export var start_offset: float = 0.0

var duration : float :
	get():
		return audio.get_length()
