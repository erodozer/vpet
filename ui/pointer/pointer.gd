extends Control

@export var follow_focus: bool = false

func _ready():
	get_viewport().gui_focus_changed.connect(
		func (ctl):
			if follow_focus:
				move_to_control(ctl)
	)

func move_to(global_pos: Vector2):
	var t := create_tween()
	var icon := get_node("TextureRect") as TextureRect
	var anim := get_node("AnimationPlayer")
	
	var from = self.global_position
	if global_pos.y < from.y:
		anim.play("swing_up")
	elif global_pos.y > from.y:
		anim.play("swing_down")
	
	t.tween_property(
		self,
		"global_position", global_pos,
		0.08
	).from(from).set_ease(Tween.EASE_IN_OUT)
	get_node("Tick").play()
	await t.finished
	
	if global_pos.y < from.y:
		anim.play_backwards("swing_up")
	elif global_pos.y > from.y:
		anim.play_backwards("swing_down")
		
func move_to_control(node: Control):
	# wait a frame in case the control moves due to scrolling
	await RenderingServer.frame_pre_draw
	
	var global_pos
	if node.has_node("%PointerAnchor"):
		var anchor = node.get_node("%PointerAnchor") as Node2D
		global_pos = anchor.global_position
	elif node.has_node("PointerAnchor"):
		var anchor = node.get_node("PointerAnchor") as Node2D
		global_pos = anchor.global_position
	else:
		global_pos = node.global_position + Vector2(0, node.size.y / 2.0)
	move_to(global_pos)
