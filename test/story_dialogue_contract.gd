extends SceneTree

const GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await _check_chapter_one_dialogue_and_greeting()
	await _check_chapter_two_dialogue()
	await _check_chapter_three_dialogue_conditions()
	if failures.is_empty():
		print("[SNACKISLE_DIALOGUE_PASS] story beats, one-shot trigger, partner high-five and chapter conditions")
	for failure in failures:
		push_error("[SNACKISLE_DIALOGUE_FAIL] " + failure)
	quit(0 if failures.is_empty() else 1)


func _make_game(chapter: int) -> Node:
	set_meta("snackisle_chapter", chapter)
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	for _frame in 3:
		await process_frame
	return game


func _remove_game(game: Node) -> void:
	game.queue_free()
	await process_frame


func _place_pair(game: Node, x: float) -> void:
	game.dudu.global_position = Vector2(x, 593.0)
	game.pochacco.global_position = Vector2(x - 24.0, 593.0)


func _check_chapter_one_dialogue_and_greeting() -> void:
	var game = await _make_game(1)
	_place_pair(game, 460.0)
	game._try_start_story_dialogue(game.get_active_buddy())
	if not game._story_dialogue_active or not game.toast_label.text.begins_with("帕恰狗：「"):
		failures.append("chapter one trail dialogue did not open with a Traditional Chinese speaker line")
	else:
		game.show_toast("普通提示不應覆蓋對話")
		if not game.toast_label.text.begins_with("帕恰狗：「"):
			failures.append("normal toast interrupted an active story dialogue")
		game._advance_story_dialogue(5.0)
		if game._story_dialogue_index != 1 or not game.toast_label.text.begins_with("嘟嘟：「"):
			failures.append("chapter one conversation did not advance to Dudu's reply")
		game._advance_story_dialogue(5.0)
		if game._story_dialogue_active or not game._story_dialogue_seen.has("ch1_strawberry_trail"):
			failures.append("chapter one dialogue did not finish and remember its one-shot trigger")
		game._try_start_story_dialogue(game.get_active_buddy())
		if game._story_dialogue_active:
			failures.append("chapter one dialogue replayed after its one-shot trigger was consumed")
	game.switch_character()
	if game.partner_greeting_cooldown <= 0.0 or game.toast_label.text.find("擊掌") < 0:
		failures.append("switching characters near each other did not play the cooldown-limited high-five")
	game.switch_character()
	if game.toast_label.text.find("現在由") < 0:
		failures.append("high-five greeting cooldown did not prevent repeated celebration spam")
	_check_touch_pointer_capture(game)
	await _remove_game(game)


func _check_chapter_two_dialogue() -> void:
	var game = await _make_game(2)
	_place_pair(game, 1540.0)
	game._try_start_story_dialogue(game.get_active_buddy())
	if not game._story_dialogue_active or game.toast_label.text.find("風車") < 0:
		failures.append("chapter two windmill dialogue did not trigger at its landmark")
	await _remove_game(game)


func _check_chapter_three_dialogue_conditions() -> void:
	var game = await _make_game(3)
	_place_pair(game, 4180.0)
	game._try_start_story_dialogue(game.get_active_buddy())
	if not game._story_dialogue_active or game.toast_label.text.find("黃銅卡榫") < 0:
		failures.append("chapter three guardian dialogue did not explain the cooperative weakness")
	game._story_dialogue_active = false
	game.chapter_three.core_unlocked = false
	_place_pair(game, 4740.0)
	game._try_start_story_dialogue(game.get_active_buddy())
	if game._story_dialogue_active:
		failures.append("chapter three ending dialogue triggered before the guardian was defeated")
	game.chapter_three.core_unlocked = true
	game._try_start_story_dialogue(game.get_active_buddy())
	if not game._story_dialogue_active or game.toast_label.text.find("鐘芯") < 0:
		failures.append("chapter three ending dialogue did not unlock after the guardian defeat")
	await _remove_game(game)


func _check_touch_pointer_capture(game: Node) -> void:
	var stick = game.touch_joystick
	if stick == null:
		failures.append("touch joystick is missing from the live game scene")
		return
	var start := InputEventScreenTouch.new()
	start.index = 21
	start.pressed = true
	start.position = stick.size * 0.5 + Vector2(0.0, -stick.size.y * 0.36)
	stick._gui_input(start)
	if stick.pointer_id != 21 or not game.touch_jump_pending:
		failures.append("touch joystick did not capture primary finger and register up-to-jump")
	var second := InputEventScreenTouch.new()
	second.index = 22
	second.pressed = true
	second.position = stick.size * 0.5 + Vector2(10.0, 10.0)
	stick._gui_input(second)
	if stick.pointer_id != 21:
		failures.append("secondary finger stole the joystick's captured pointer")
	var release := InputEventScreenTouch.new()
	release.index = 21
	release.pressed = false
	stick._gui_input(release)
	if stick.pointer_id != -1 or game.touch_move_axis != 0.0:
		failures.append("joystick failed to reset when its controlling finger lifted")
	Input.action_press("jump")
	game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	if Input.is_action_pressed("jump"):
		failures.append("jump action stayed held after application focus loss")
	Input.action_release("jump")
