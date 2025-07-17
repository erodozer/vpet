extends PanelContainer

@onready var song_title: Label = get_node("%SongTitle")
@onready var duration_label: Label = get_node("%Duration")

var overrun_tween: Tween

@export var song: DJSongResource :
	set(v):
		var width = song_title.get_theme_font("font", song_title.theme_type_variation).get_string_size(v.title).x
		var vis = song_title.get_parent().size.x
		
		if overrun_tween != null:
			overrun_tween.kill()
			
		song_title.text = v.title
		if width > vis:
			var t = create_tween()
			t.tween_property(song_title, "position:x", vis - width, 1.0).set_delay(3.0)
			t.tween_property(song_title, "position:x", 0, 1.0).set_delay(3.0)
			t.set_loops()
			
			overrun_tween = t
		
@export var player: AudioStreamPlayer

func _on_notes_ready(notes: Array[float], song: DJSongResource) -> void:
	self.song = song

func _process(delta: float) -> void:
	if player.stream == null:
		return
		
	duration_label.text = "%d:%02d / %d:%02d" % [
		int(player.get_playback_position()) / 60,
		int(player.get_playback_position()) % 60,
		int(player.stream.get_length()) / 60,
		int(player.stream.get_length()) % 60,
	]
