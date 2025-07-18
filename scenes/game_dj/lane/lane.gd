extends Control

const Rating = preload("res://scenes/game_dj/enum.gd").Rating
const SCROLL_RATE = 160 / 2.0

const HIT_WINDOW = Vector2(-0.15, 0.10)
const GOOD_WINDOW = Vector2(-0.10, 0.08)
const GREAT_WINDOW = Vector2(-0.05, 0.03)

@onready var note_sheet = get_node("%Notes")
@onready var cursor = get_node("%Cursor")
@onready var particles = get_node("%Explode")

var notes: Array[Node] = []
var progress: float = 0.0
var index = 0

var scroll_rate = SCROLL_RATE

signal play_note(rating: Rating)

func current_note():
	if index >= len(notes):
		return null
	return notes[index]

func render_notes(notes: Array[float], song: DJSongResource):
	scroll_rate = SCROLL_RATE * song.bpm / 100.0
	
	for t in notes:
		var note = Sprite2D.new()
		note.centered = true
		note.texture = load("res://scenes/game_dj/lane/note.png")
		note.position = Vector2(-scroll_rate * t + cursor.position.x + (cursor.size.x / 2), 0)
		note.set_meta("time", t)
		
		note_sheet.add_child(note)
	
	self.notes = note_sheet.get_children()
	progress = 0.0

func note_hit(t: float, range: Vector2 = HIT_WINDOW) -> bool:
	return progress > t + range.x and progress < t + range.y
	
var mouse_pressed = false
func _input(event: InputEvent) -> void:
	var pressed = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not mouse_pressed:
			pressed = true
			mouse_pressed = true
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			mouse_pressed = false
	if event.is_action_pressed("ui_accept"):
		pressed = true
	
	if not pressed:
		return
		
	var tween = create_tween()
	tween.parallel().tween_property(
		cursor, "scale", Vector2(1.05, 1.05), 0.08
	)
	tween.tween_property(
		cursor, "scale", Vector2(1.0, 1.0), 0.14
	).set_ease(Tween.EASE_IN_OUT)	
	
	tween = create_tween()
	tween.tween_property(
		%Highlight, "scale:y", 1.0, 0.1
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		%Highlight, "scale:y", 0.0, 0.1
	).set_ease(Tween.EASE_IN_OUT).set_delay(0.04)
	
	var note = current_note()
	if note == null:
		return
	var t = note.get_meta("time")
	if note_hit(t):
		var rating: Rating = Rating.OK
		if note_hit(t, GREAT_WINDOW):
			rating = Rating.GREAT
		elif note_hit(t, GOOD_WINDOW):
			rating = Rating.GOOD
		
		play_note.emit(rating)
		
		#note.reparent(self, true)
		tween = create_tween()
		tween.parallel().tween_property(
			note, "modulate", Color(0,0,0,0), 0.15
		).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(
			note, "scale", Vector2(1.1, 1.1), 0.15
		).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(
			note, "position:y", -12.0, 0.15
		).set_ease(Tween.EASE_OUT)
		
		particles.emitting = true
		index += 1
	else:
		play_note.emit(Rating.BAD)
	
func _process(delta: float) -> void:
	progress += delta
	note_sheet.position.x = progress * scroll_rate
	
	var note = current_note()
	if note == null:
		return
	
	var t = note.get_meta("time")	
	if t + HIT_WINDOW.y < progress:
		create_tween().tween_property(
			note, "modulate", Color(0.2,0.2,0.2,.5), 0.1
		).set_ease(Tween.EASE_IN_OUT)
		index += 1
		# miss
		play_note.emit(Rating.MISS)
	
