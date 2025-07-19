extends Node2D

var left_bound
var right_bound

@onready var sprite: AnimatedSprite2D = get_node("Sprite2D")
@onready var dirty = get_node("Dirty")

var tween: Tween
var pause = false: set = set_paused

var next_action = 0

var anims = {
	"idle": [],
	"eat": []
}

func _ready():
	GameState.connect("stats_changed", Callable(self, "_update_stats"))
	(get_node("FollowCamera") as Camera2D).make_current()
	
	for i in sprite.sprite_frames.get_animation_names():
		if i.begins_with("idle") and i != "idle:overfed":
			anims.idle.append(i)
		elif i.begins_with("eat") and i != "eat:overfed":
			anims.eat.append(i)
			
	if get_parent() != null:
		var bounds = Vector2(
			(get_parent() as Control).get_rect().size.x / -2 + (get_parent() as Control).position.x,
			(get_parent() as Control).get_rect().size.x / 2 + (get_parent() as Control).position.x
		)
		left_bound = bounds.x
		right_bound = bounds.y
	else:
		left_bound = position.x - 10
		right_bound = position.x + 10
	
func _update_stats(stats):
	dirty.visible = false
	
	if stats.is_asleep:
		_rest()
	elif stats.sick > 75.0:
		_sick()
	else:
		dirty.visible = stats.dirty > 50.0

func set_paused(value = false):
	pause = value
	if value and tween:
		tween.kill()
		tween = null

func move_to(target: Vector2, padding = 0):
	# move clover over to the point on the floor
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	var facing = sign(position.x - target.x)
	var destination = target.x + (padding * sign(facing))
	
	tween.tween_property(
		self, "position:x", destination, 2.0
	)
	
	var facing_dest = sign(position.x - destination)
	sprite.scale.x = facing_dest
	if GameState.is_fat and sprite.sprite_frames.has_animation("walk:overfed"):
		sprite.play("walk:overfed")
	else:
		sprite.play("walk")
	
	# wait for clover to get to the food
	await tween.finished
	sprite.scale.x = facing
	
	if GameState.is_fat and sprite.sprite_frames.has_animation("idle:overfed"):
		sprite.play("idle:overfed")
	else:
		_play_random_anim("idle")
	
func eat():
	if GameState.is_fat and sprite.sprite_frames.has_animation("eat:overfed"):
		sprite.play("eat:overfed")
	else:
		_play_random_anim("eat")
	
func _wander():
	$Sickness.visible = false
	
	# chance to just switch to a different idle anim
	if randf() < 0.35:
		next_action = GameState.now() + randf_range(4.0, 10.0)
		_play_random_anim("idle")
	else:
		next_action = GameState.now() + randf_range(3.0, 12.0)
	
		# move action
		var next = randf_range(left_bound, right_bound)	
		move_to(Vector2(next, 0.0))
	
func _play_random_anim(style):
	if randf() < 0.5:
		sprite.play(style)
	else:
		sprite.play(anims[style][randi() % len(anims[style])])
	
func _rest():
	if pause:
		return
	$Sickness.visible = false
	sprite.play("sleep")
	sprite.scale.x = 1.0

func _sick():
	if pause:
		return
	$Sickness.visible = true
	sprite.play("sick")
	sprite.scale.x = 1.0
	
func _process(_delta):
	if pause:
		return
	elif not is_inside_tree():
		return
	elif GameState.stats.is_asleep:
		return
	elif GameState.stats.sick > 75.0:
		return
	elif GameState.now() < next_action:
		return
	
	_wander()
