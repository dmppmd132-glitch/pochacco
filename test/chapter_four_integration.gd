extends SceneTree

const GAME_SCRIPT := preload("res://scripts/snackisle_game.gd")

var failures: Array[String] = []


func _initialize() -> void:
	set_meta("snackisle_chapter", 4)
	call_deferred("_run")


func _run() -> void:
	var store := root.get_node_or_null("SaveStore")
	var old_store_data: Dictionary = store.data.duplicate(true) if is_instance_valid(store) else {}
	var save_path: String = store.SAVE_PATH if is_instance_valid(store) else ""
	var had_save := not save_path.is_empty() and FileAccess.file_exists(save_path)
	var old_save_text := FileAccess.get_file_as_string(save_path) if had_save else ""
	var game = GAME_SCRIPT.new()
	root.add_child(game)
	await process_frame
	_expect(game.chapter_index == 4, "game accepts chapter four selection")
	_expect(is_instance_valid(game.chapter_four), "chapter four creates its mechanics controller")
	_expect(is_instance_valid(game.chapter_four_gate), "echo puzzle begins behind a gate")
	_expect(is_instance_valid(game.chapter_four_mirror_gate), "prism puzzle begins behind a gate")

	var entry_floor_found := false
	var echo_area_floor_found := false
	var reef_area_floor_found := false
	var safe_route_found := false
	var optional_route_stars := 0
	for platform in get_nodes_in_group("pastry_platform"):
		var left: float = platform.position.x - platform.size.x * 0.5
		var right: float = platform.position.x + platform.size.x * 0.5
		if is_equal_approx(platform.position.y - platform.size.y * 0.5, game.GROUND_Y):
			if left <= 150.0 and right >= 150.0:
				entry_floor_found = true
			if left <= 2100.0 and right >= 2100.0:
				echo_area_floor_found = true
			if left <= 3200.0 and right >= 3200.0:
				reef_area_floor_found = true
			if left <= 4300.0 and right >= 4300.0:
				safe_route_found = true
		_expect(right > left, "all route platforms have positive width")
	for candy in get_nodes_in_group("star_candy"):
		if str(candy.get_meta("route_id", "main")) == "optional_moon_sugars":
			optional_route_stars += 1
		_expect(entry_floor_found, "spawn point is supported by a real entry-area floor")
		_expect(echo_area_floor_found, "the echo corridor main route remains on a traversable floor")
		_expect(reef_area_floor_found, "the reef area main route remains below the optional branch")
		_expect(safe_route_found, "the safe main route reaches the lighthouse approach")
	_expect(optional_route_stars == 3, "the optional reef branch has exactly three bonus stars")
	_expect(game.checkpoint_x < 4180.0, "boss checkpoint is not granted before approaching its threshold")
	game.dudu.global_position.x = 4181.0
	game.on_buddy_moved_checkpoint_check()
	_expect(game.checkpoint_x == 4200.0, "boss-door approach activates a checkpoint before the boss trigger")

	var controller = game.chapter_four
	controller.begin_echo()
	controller.advance(2.5)
	_expect(controller.echo_state == controller.EchoState.INPUT, "echo cue becomes playable")
	_expect(controller.input_tone(0), "first tone is accepted")
	_expect(controller.input_tone(2), "second tone is accepted")
	_expect(controller.input_tone(1), "third tone solves the echo")
	await process_frame
	_expect(game.chapter_four_gate == null, "solving echo opens its coral gate")
	_expect(controller.rotate_mirror(0), "echo solution enables mirror interaction")
	_expect(not controller.prism_lit, "one aligned mirror does not solve the path")
	_expect(controller.rotate_mirror(1), "second mirror rotates")
	_expect(controller.prism_lit, "aligned mirrors reach the receiver")
	await process_frame
	_expect(game.chapter_four_mirror_gate == null, "receiver activation opens the glass reef gate")

	var boss = game.chapter_four_boss
	_expect(is_instance_valid(boss), "tidal jellyfish boss is present in the fourth-chapter world")
	_expect(is_instance_valid(game.chapter_four_boss_gate), "moonlight pearl is protected by a closed gate")
	boss.core_hits = boss.REQUIRED_CORE_HITS
	boss._set_state(boss.State.DEFEATED)
	game.on_tidal_jellyfish_defeated(boss)
	_expect(game.chapter_four_boss_gate == null, "boss victory removes the pearl-room gate")
	_expect(not game.run_over, "defeating the boss alone does not finish the chapter")
	if is_instance_valid(store):
		game.star_candies = 4
		game.chapter_four_run_id = "chapter-four-smoke-%d" % Time.get_ticks_usec()
		game.dudu.global_position = Vector2(4950.0, game.GROUND_Y - 48.0)
		game._process(0.016)
		_expect(game.run_over, "touching the moonlight pearl opens the chapter results")
		_expect(game.chapter_four_reward_saved, "chapter result saves its collected stars")
		_expect(store.claim_star_candy_reward(game.chapter_four_run_id, 40), "same run can be retried as a successful no-op")
		_expect(store.get_star_candy_balance() == int(old_store_data.get("star_candy_balance", 0)) + 4, "same run retry cannot credit a second reward")
		_expect(game.result_overlay.find_child("ResultBody", true, false).text.contains("已保存的星星糖餘額"), "result copy reports saved balance only after save succeeds")
	else:
		_expect(false, "SaveStore autoload is available for chapter result integration")

	if is_instance_valid(store):
		store.data = old_store_data
		if had_save:
			_expect(_write_text(save_path, old_save_text), "original save file can be restored")
		else:
			var absolute_path := ProjectSettings.globalize_path(save_path)
			if FileAccess.file_exists(save_path):
				_expect(DirAccess.remove_absolute(absolute_path) == OK, "temporary integration save can be removed")
			store.load_save()
	for failure in failures:
		push_error("[CHAPTER_FOUR_INTEGRATION_FAIL] " + failure)
	if failures.is_empty():
		print("[CHAPTER_FOUR_INTEGRATION_PASS] entrance, safe route, optional stars, checkpoints, both puzzle gates, boss gate, pearl-only finish and reward idempotency")
	quit(0 if failures.is_empty() else 1)


func _write_text(path: String, content: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.close()
	return true


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
