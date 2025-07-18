extends Node

const gdsh = preload("res://addons/godash/godash.gd")

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	SPECIAL
}

const MAX_PITY = 10

var available_cards = []

func _setup(_params):
	var buttons = []
	%Purchase.get_children().map(
		func (c):
			if c is Button:
				c.pressed.connect(_on_button_pressed.bind(c))
				var cost: int = c.get_meta("cost")
				c.disabled = GameState.stats.honey < cost
				buttons.append(c)
	)
	buttons[0].grab_focus()
	
	var pity = GameState.extra.get("gacha", {}).get("pity", 0)
	%Pity.text = "Pity %d of %d" % [pity, MAX_PITY]
	
	available_cards = []
	for p in AppSkin.enumerate_dir("res://resources/gacha/"):
		available_cards.append(load(p))
	update_score(0)
	
func quit():
	SceneManager.change_scene("home")
	
func update_score(amount: float):
	%ScoreLabel.text = "%.2f %s" % [amount, ProjectSettings.get_setting_with_override("application/vpet/gacha_points")]
	
func rarity_category(rarity: float) -> Rarity:
	if rarity < 0.5: # 50% chance
		return Rarity.COMMON
	elif rarity < 0.80: # 30% chance
		return Rarity.UNCOMMON
	elif rarity < 0.97: # 15% chance
		return Rarity.RARE
	else: # 2% chance
		return Rarity.SPECIAL
	
func render_card(card: Dictionary, records: Dictionary, history: Dictionary):
	var node = preload("./card.tscn").instantiate()
	
	var card_id = card.id
	var rarity = rarity_category(card.rarity)
	var seen = history.get(card_id, -1)
	node.get_node("%IsNew").visible = seen == -1 and card.rarity >= records[card_id]
	node.get_node("%IsBest").visible = seen > 0 and card.rarity >= records[card_id]
	node.get_node("%Face").texture = card.face
	
	match rarity:
		Rarity.SPECIAL:
			node.get_node("%Base").texture = load("res://scenes/game_gacha/card_special.png")
		Rarity.RARE:
			node.get_node("%Base").texture = load("res://scenes/game_gacha/card_rare.png")
		Rarity.UNCOMMON:
			node.get_node("%Base").texture = load("res://scenes/game_gacha/card_uncommon.png")
		_:
			node.get_node("%Base").texture = load("res://scenes/game_gacha/card_front.png")
		
	add_child(node)
	
	return node

func render_deck(cards: Array, records: Dictionary, history: Dictionary):
	var amount = len(cards)
	var t = create_tween()
	var col_max: float = 5.0 if amount > 5 else 3.0
	var n = 0
	var r = 0
	var c = 0
	
	for i in cards:
		var y = 10 + (44 * r)
		var cards_in_row = min(len(cards) - (col_max * r), col_max)
		var spacing = min(70 / cards_in_row, 16)
		var x = 80 + lerp(-cards_in_row * spacing, spacing * cards_in_row - 24, float(c) / (cards_in_row - 1))
	
		var card = render_card(i, records, history)
		card.position = Vector2(x, -100)
		t.tween_property(card, "position", Vector2(x, y), 0.15).set_delay(0.05).set_ease(Tween.EASE_IN_OUT)
		t.parallel().tween_callback(card.get_node("AudioStreamPlayer").play)
	
		n += 1
		c += 1
		if c >= col_max:
			c = 0
			r += 1
	
		
	
func _on_button_pressed(btn: Button):
	var cost: int = btn.get_meta("cost")
	if cost == 0:
		# exit early without costing play time
		quit()
		return
	
	# check cost
	if GameState.stats.honey < cost:
		return
		
	var state = GameState.extra.get("gacha", {})
	NoClick.show()
	$AnimationPlayer.play("select")
	await $AnimationPlayer.animation_finished
	
	var amount: int = btn.get_meta("buy")
	
	# builds the pull
	var cards = []
	var pity = state.get("pity", 0)
	for i in range(amount):
		var rarity = randf()
		var category: Rarity = rarity_category(rarity)
				
		if category in [Rarity.RARE, Rarity.SPECIAL]:
			pity = 0
		elif pity + 1 > MAX_PITY:
			pity = 0
			rarity = [Rarity.RARE, Rarity.SPECIAL].pick_random()
		else:
			pity += 1
			
		var card = available_cards.pick_random()
		cards.append({ "id": card.id, "rarity": rarity, "value": card.price, "face": card.image })
	
	var card_history: Dictionary = state.get("cards", {})
	
	var records: Dictionary = cards.reduce(
		func (acc, card):
			var seen = acc.get(card.id, -1)
			if card.rarity > seen:
				acc[card.id] = card.rarity
			return acc,
		card_history.duplicate(),
	)
	
	var happiness = cards.reduce(
		func (acc, card):
			var seen = card_history.get(card.id, -1)
			var is_new = seen == -1 and card.rarity >= records[card.id]
			var is_best = seen >= 0 and card.rarity >= records[card.id]
		
			var bonus = 10
			if is_new:
				bonus += 30
			if is_best:
				bonus += 10
			match rarity_category(card.rarity):
				Rarity.UNCOMMON:
					bonus += 3
				Rarity.RARE:
					bonus += 5
				Rarity.SPECIAL:
					bonus += 10
				_:
					pass
			return bonus,
		0
	)
	
	var score = cards.reduce(
		func (acc, card):
			var value = card.value * lerp(0.5, 2.0, card.rarity)
			return acc + value,
		0
	)
	
	render_deck(cards, records, card_history)

	%Pet.play("dance")
	await create_tween().tween_method(self.update_score, 0, score, 0.20 * amount).finished
	%Pet.play("idle")
	
	await get_tree().create_timer(3.0).timeout
	%Results/%Currency.text = "%d" % [score - cost]
	%Results/%Happiness.text = "%d" % [happiness]
	%Results/%AnimationPlayer.play("show")
	await get_tree().create_timer(3.0).timeout
	
	card_history.merge(records)
	
	GameState.stats = {
		# boredom goes down relative to card rarity and newness
		"boredom": GameState.stats.boredom - happiness,
		# spend honey to play
		"honey": GameState.stats.honey + score - cost,
	}
	GameState.timers = {
		GameState.GameActions.Play: GameState.now() + 180, # 3 minutes
	}
	GameState.extra["gacha"] = {
		"pity": pity,
		"cards": card_history
	}
	NoClick.hide()
	quit()
