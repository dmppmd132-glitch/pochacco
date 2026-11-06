extends SceneTree

const TITLE_SCENE := preload("res://scenes/title_screen.tscn")
const GAME_SCENE := preload("res://scenes/game.tscn")
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	for _frame in 3:
		await process_frame
	var i18n := root.get_node_or_null("I18n")
	_check(i18n != null and i18n.get_locale() == "zh-TW", "game locale is pinned to Traditional Chinese")
	var title := TITLE_SCENE.instantiate()
	root.add_child(title)
	current_scene = title
	for _frame in 3:
		await process_frame
	var start_button: Button = title.find_child("StartAdventure", true, false)
	_check(start_button != null and start_button.text == "開始冒險", "title screen presents the playable game entry")
	_check(title.find_child("GameTitle", true, false) != null, "title card is present")
	if start_button == null:
		_finish()
		return
	start_button.pressed.emit()
	for _frame in 8:
		await process_frame
	var game := current_scene
	var game_script: Script = game.get_script() if game != null else null
	_check(game_script != null and game_script.resource_path == "res://scripts/snackisle_game.gd", "active scene runs the new Strawberry Cake Village script")
	_check(game != null and game.scene_file_path == "res://scenes/game.tscn", "start button enters Strawberry Cake Village")
	if game == null or not game.has_method("switch_character"):
		_finish()
		return
	for _frame in 3:
		await process_frame
	_check(game.health == 3 and game.hearts_view.health == 3, "three strawberry mochi hearts start full")
	_check(game.dudu != null and game.pochacco != null, "both playable companions are spawned")
	_check(game.active_is_dudu() and game.get_active_buddy() == game.dudu, "Dudu leads at the start")
	game.switch_character()
	_check(game.active_is_pochacco() and game.get_active_buddy() == game.pochacco, "instant character switching makes Pochacco controllable")
	game.switch_character()
	_check(game.active_is_dudu() and game.get_active_buddy() == game.dudu, "instant switching returns control to Dudu")
	game.perform_attack(game.dudu)
	_check(game.dudu.roll_time > 0.0, "Dudu roll ability starts")
	var before_projectiles := game.get_child_count()
	game.perform_attack(game.pochacco)
	_check(game.get_child_count() > before_projectiles, "Pochacco throws a returning banana projectile")
	game.pochacco.global_position = Vector2(1560.0, game.GROUND_Y - 27.0)
	game.dudu.global_position = Vector2(1500.0, game.GROUND_Y - 27.0)
	game.clues_visible = false
	game.break_barrier(game.hidden_wall)
	_check(is_instance_valid(game.hidden_wall), "hidden chocolate wall cannot be broken before sniffing it out")
	game.switch_character()
	game.detect_clues()
	_check(game.clues_visible, "Pochacco sniff reveals hand-drawn footprints")
	game.switch_character()
	game.dudu.global_position = Vector2(1500.0, game.GROUND_Y - 27.0)
	game.dudu.facing = 1.0
	game.dudu.velocity = Vector2.ZERO
	Input.action_press("move_right")
	game.perform_attack(game.get_active_buddy())
	for _frame in 12:
		await physics_frame
	Input.action_release("move_right")
	_check(game.hidden_wall == null, "Dudu rolls into the discovered wall and breaks it")
	game.dudu.global_position = Vector2(860.0, game.GROUND_Y - 27.0)
	game.dudu.velocity = Vector2.ZERO
	for _frame in 3:
		await physics_frame
	game.request_gather()
	_check(game.team_weight_activated and game.team_gate == null, "F gather hug activates the two-companion weight gate")
	game.switch_character()
	game.pochacco.global_position = Vector2(game.plate_x, game.GROUND_Y - 27.0)
	game.pochacco.velocity = Vector2.ZERO
	for _frame in 5:
		await physics_frame
	_check(game.plate_pressed and game.plate_is_held(), "Pochacco holds the jam-river bridge switch while Dudu can be selected")
	game.switch_character()
	game.dudu.global_position = Vector2(1400.0, game.GROUND_Y - 27.0)
	game.pochacco.global_position = Vector2(1390.0, game.GROUND_Y - 27.0)
	game.dudu.velocity = Vector2.ZERO
	game.pochacco.velocity = Vector2.ZERO
	game.switch_character()
	game.pochacco.global_position = Vector2(1450.0, game.GROUND_Y - 27.0)
	game.dudu.global_position = Vector2(900.0, game.GROUND_Y - 27.0)
	for _frame in 2:
		await physics_frame
	_check(game.dudu.roll_time > 0.0, "AI Dudu auto-rolls to catch up when Pochacco sprints ahead")
	game.switch_character()
	game.dudu.global_position = Vector2(2992.0, game.GROUND_Y - 27.0)
	game.dudu.facing = 1.0
	game.dudu.velocity = Vector2.ZERO
	game.pochacco.global_position = Vector2(game.plate_x, game.GROUND_Y - 27.0)
	game.pochacco.velocity = Vector2.ZERO
	for _frame in 5:
		await physics_frame
	_check(game.plate_pressed and game.plate_is_held(), "Pochacco keeps the jam-river bridge plate while Dudu leads")
	game.perform_attack(game.dudu)
	for _frame in 12:
		await physics_frame
	_check(game.bridge_cookie == null and game.plate_is_held(), "Dudu's roll breaks the bridge cookie while Pochacco holds the plate")
	var initial_stars: int = int(game.star_candies)
	game._add_star(Vector2(2000, 500))
	var candy = game.get_child(game.get_child_count() - 1)
	game.collect_star(candy)
	_check(game.star_candies == initial_stars + 1, "star candy pickup updates the backpack counter")
	var initial_food: int = int(game.strawberry_ingredients)
	game._add_ingredient(Vector2(2000, 500))
	var food_item = game.get_child(game.get_child_count() - 1)
	game.collect_ingredient(food_item)
	_check(game.strawberry_ingredients == initial_food + 1 and game.ingredients_label.text == "食材 01", "strawberry ingredient pickup updates the chick backpack count")
	game.switch_character()
	game.pochacco.global_position = Vector2(game.boss_x - 58.0, game.GROUND_Y - 27.0)
	game.pochacco.facing = 1.0
	game.drop_banana_peel(game.get_active_buddy())
	for _frame in 3:
		await physics_frame
	_check(game.boss_exposed_time > 0.0 and not game.banana_peel_placed, "Pochacco's banana peel makes the cream boss slip and expose its core")
	game.switch_character()
	game.dudu.global_position = Vector2(game.boss_x, game.GROUND_Y - 132.0)
	game.dudu.velocity = Vector2.ZERO
	for _frame in 2:
		await physics_frame
	game.dudu.start_ground_pound()
	for _frame in 12:
		await physics_frame
	_check(game.boss_defeated, "Dudu's real ground-pound landing defeats the exposed cream boss core nonviolently")
	game.open_pause()
	_check(paused and game.pause_overlay != null, "pause opens its game overlay")
	game.resume_game()
	_check(not paused, "resume closes pause and restores play")
	Input.action_press("move_right")
	for _frame in 240:
		await physics_frame
		if game.run_over:
			break
	Input.action_release("move_right")
	_check(game.run_over and game.result_overlay != null, "walking to the recovered strawberry fountain valve opens the chapter result")
	_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for message in failures:
		push_error("[SNACKISLE_SMOKE_FAIL] " + message)
	if failures.is_empty():
		print("[SNACKISLE_SMOKE_PASS] title, zh-TW, duo switch/follow, both abilities, clue-gated wall, hug gate, bridge plate, health, star/ingredient backpack, banana-peel boss slip, ground-pound victory, pause and result")
	var audio := root.get_node_or_null("GameAudio")
	if audio != null and audio.has_method("stop_game"):
		audio.stop_game()
	quit(0 if failures.is_empty() else 1)
