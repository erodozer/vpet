extends Node

const gdsh = preload("res://addons/godash/godash.gd")
const Rating = preload("./enum.gd").Rating

var progress = 0
var notes = []
var hit = 0
var combo = 0 :
	set(v):
		combo = v
		max_combo = max(max_combo, combo)
var max_combo = 0

signal play_note(
	rating: Rating,
	combo: int
)
signal notes_ready(notes: Array[float])

func _start():
	_game()

func _game():
	var songfiles = AppSkin.enumerate_dir("res://scenes/game_dj/songs", "tres")
	var songfile = songfiles.pick_random()
	if songfile == null:
		return
	var song: DJSongResource = load(songfile)
	var playback: AudioStreamPlayer = get_node("%Song")
	playback.stream = song.audio
	playback.finished.connect(self.game_finished)
	
	var t = song.start_offset
	var d = song.duration
	var notes: Array[float] = []
	while t + 2.0 < d:
		t += [
				0.25,
				0.5,
				0.75,
				1.0,
				2.0
			].pick_random()
		notes.append(t)
		
	notes_ready.emit(notes)
	
	playback.play()

func game_finished():
	await get_tree().create_timer(1.5).timeout
	
	var perfect_combo = max_combo == len(notes)
	var score = 1000 * float(hit) / len(notes)
	score += 500 if perfect_combo else 0
	score += 500 * float(max_combo) / len(notes)
	var happy = inverse_lerp(0, 2000, score)

	NoClick.show()
	%Results/%Currency.text = "+%d" % [score]
	%Results/%Happiness.text = "%d" % [happy]
	%Results/%AnimationPlayer.play("show")
	await %Results/%AnimationPlayer.animation_finished
	NoClick.hide()
	
	GameState.stats = {
		# boredom goes down relative to speed of success
		"boredom": GameState.stats.boredom - happy,
		# also grand bonus Honey as a prize
		"honey": GameState.stats.honey + score,
	}
	GameState.timers = {
		GameState.GameActions.Play: GameState.now() + 420, # 7 minutes
	}
	
	SceneManager.change_scene("home")

func _on_note_played(rating: Rating) -> void:
	match rating:
		Rating.MISS, Rating.BAD:
			combo = 0
		_:
			combo += 1
			hit += 1
	play_note.emit(rating, combo)
