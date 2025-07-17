extends PanelContainer

@onready var song_title: Label = get_node("%SongTitle")
@onready var duration_label: Label = get_node("%Duration")

@export var song: DJSongResource :
	set(v):
		song_title.text = v.title
@export var player: AudioStreamPlayer

func _on_notes_ready(notes: Array[float], song: DJSongResource) -> void:
	self.song = song

func _process(delta: float) -> void:
	if player.stream == null:
		return
		
	duration_label.text = "%02d:%02d / %02d:%02d" % [
		int(player.get_playback_position()) / 60,
		int(player.get_playback_position()) % 60,
		int(player.stream.get_length()) / 60,
		int(player.stream.get_length()) % 60,
	]
