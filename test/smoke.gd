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
	var chapter_two_button: Button = title.find_child("StartChapterTwo", true, false)
	var wardrobe_button: Button = title.find_child("WardrobeButton", true, false)
	var controls_hint: Label = title.find_child("ControlsHint", true, false)
	_check(start_button != null and start_button.text == "開始冒險", "title screen presents the playable game entry")
	_check(chapter_two_button != null and chapter_two_button.text == "體驗第二章｜雲朵森林", "title screen provides a localized Chapter Two entry")
	_check(wardrobe_button != null and wardrobe_button.text == "衣櫃換裝", "title screen provides a wardrobe entry")
	_check(controls_hint != null and controls_hint.text.contains("觸控／手把"), "title explains the new gamepad-style touch controls")
	_check(title.find_child("GameTitle", true, false) != null, "title card is present")
	if wardrobe_button != null:
		wardrobe_button.pressed.emit()
		for _wardrobe_open_frame in 3:
			await process_frame
		var wardrobe := title.find_child("WardrobeScreen", true, false)
		_check(wardrobe != null and paused, "wardrobe opens as a pause-owning modal")
		if wardrobe != null:
			_check(wardrobe.find_child("CostumeList", true, false) != null, "wardrobe shows the costume catalog")
			wardrobe.close_panel()
			for _wardrobe_close_frame in 2:
				await process_frame
		_check(not paused, "closing the wardrobe restores the previous pause state")
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
	var game_constants: Dictionary = game.get_script().get_script_constant_map()
	var opening_platform_rise: float = float(game_constants["GROUND_Y"]) - float(game_constants["START_PLATFORM_TOP"])
	var dudu_jump_speed: float = float(game_constants["DUDU_JUMP_SPEED"])
	var dudu_jump_apex: float = dudu_jump_speed * dudu_jump_speed / (2.0 * float(game_constants["GRAVITY"]))
	_check(dudu_jump_apex >= opening_platform_rise + 16.0, "Dudu cannot reach the first chiffon platform with safe clearance")
	for _frame in 3:
		await process_frame
	_check(game.health == 3 and game.hearts_view.health == 3, "three strawberry mochi hearts start full")
	_check(game.dudu != null and game.pochacco != null, "both playable companions are spawned")
	_check(game.active_is_dudu() and game.get_active_buddy() == game.dudu, "Dudu leads at the start")
	for key in ["A", "B", "X", "Y", "L", "R"]:
		var pad_button := game.touch_buttons.get(key) as Button
		_check(pad_button != null, "touch pad includes %s button" % key)
	_check(game.touch_buttons["A"].text == "A\n跳躍" and game.touch_buttons["B"].text == "B\n滾動", "Dudu touch labels show A jump and B roll")
	_check(game.touch_buttons["X"].text == "X\n坐擊" and game.touch_buttons["R"].text == "R\n攻略", "Dudu touch labels show X ground pound and R guide")
	_check(_has_joypad_button("jump", JOY_BUTTON_A), "physical gamepad A maps to jump")
	game.touch_buttons["A"].button_down.emit()
	_check(Input.is_action_pressed("jump"), "touch A presses the jump action")
	game.touch_buttons["A"].button_up.emit()
	_check(not Input.is_action_pressed("jump"), "releasing touch A releases the jump action")
	_check(_has_joypad_button("attack", JOY_BUTTON_B) and not _has_joypad_button("attack", JOY_BUTTON_X), "physical gamepad B maps to attack instead of X")
	_check(_has_joypad_button("ground_pound", JOY_BUTTON_X) and _has_joypad_button("sniff", JOY_BUTTON_X), "physical gamepad X maps to the character's special")
	_check(_has_joypad_button("assemble", JOY_BUTTON_Y), "physical gamepad Y maps to gather hug")
	_check(_has_joypad_button("switch_character", JOY_BUTTON_LEFT_SHOULDER), "physical gamepad L shoulder switches characters")
	_check(_has_joypad_button("guide_or_peel", JOY_BUTTON_RIGHT_SHOULDER), "physical gamepad R shoulder opens Dudu guide or Pochacco peel")
	var controller_b := InputEventJoypadButton.new()
	controller_b.button_index = JOY_BUTTON_B
	controller_b.pressed = true
	game._unhandled_input(controller_b)
	_check(not paused, "B attack does not trigger the shared ui_cancel pause mapping")
	game.touch_buttons["R"].pressed.emit()
	var guide_copy := ""
	if game.pause_overlay != null:
		for node in game.pause_overlay.find_children("*", "Label", true, false):
			guide_copy += (node as Label).text + "\n"
	_check(paused and guide_copy.contains("攻略說明") and guide_copy.contains("第一章"), "Dudu R opens a chapter strategy guide")
	game.resume_game()
	var joystick: Control = game.find_child("TouchJoystick", true, false)
	_check(joystick != null and joystick.size.x >= 112.0, "a large virtual joystick is available for phone movement")
	if joystick != null:
		var touch_down := InputEventScreenTouch.new()
		touch_down.index = 3
		touch_down.pressed = true
		touch_down.position = joystick.size * 0.5
		joystick.call("_gui_input", touch_down)
		var drag_right := InputEventScreenDrag.new()
		drag_right.index = 3
		drag_right.position = joystick.size * 0.5 + Vector2(joystick.size.x * 0.24, 0.0)
		joystick.call("_gui_input", drag_right)
		_check(game.touch_move_axis > 0.5, "dragging the virtual joystick moves the active buddy right")
		var touch_up := InputEventScreenTouch.new()
		touch_up.index = 3
		touch_up.pressed = false
		touch_up.position = drag_right.position
		joystick.call("_gui_input", touch_up)
		_check(is_zero_approx(game.touch_move_axis), "releasing the virtual joystick stops movement")
		var jump_down := InputEventScreenTouch.new()
		jump_down.index = 4
		jump_down.pressed = true
		jump_down.position = joystick.size * 0.5
		joystick.call("_gui_input", jump_down)
		var drag_up := InputEventScreenDrag.new()
		drag_up.index = 4
		drag_up.position = joystick.size * 0.5 + Vector2(0.0, -joystick.size.y * 0.25)
		joystick.call("_gui_input", drag_up)
		_check(game.consume_touch_jump(), "an upward joystick flick queues a jump")
		var jump_release := InputEventScreenTouch.new()
		jump_release.index = 4
		jump_release.pressed = false
		jump_release.position = drag_up.position
		joystick.call("_gui_input", jump_release)
	game.touch_buttons["L"].pressed.emit()
	_check(game.active_is_pochacco() and game.get_active_buddy() == game.pochacco, "instant character switching makes Pochacco controllable")
	_check(game.touch_buttons["B"].text == "B\n迴旋" and game.touch_buttons["X"].text == "X\n嗅嗅" and game.touch_buttons["R"].text == "R\n蕉皮", "Pochacco touch labels update B/X/R actions")
	game.touch_buttons["L"].pressed.emit()
	_check(game.active_is_dudu() and game.get_active_buddy() == game.dudu, "instant switching returns control to Dudu")
	game.touch_buttons["B"].pressed.emit()
	_check(game.dudu.roll_time > 0.0, "Dudu roll ability starts")
	var before_projectiles := game.get_child_count()
	game.touch_buttons["L"].pressed.emit()
	game.touch_buttons["B"].pressed.emit()
	_check(game.get_child_count() > before_projectiles, "Pochacco throws a returning banana projectile")
	game.touch_buttons["L"].pressed.emit()
	game.pochacco.global_position = Vector2(1560.0, game.GROUND_Y - 27.0)
	game.dudu.global_position = Vector2(1500.0, game.GROUND_Y - 27.0)
	game.clues_visible = false
	game.break_barrier(game.hidden_wall)
	_check(is_instance_valid(game.hidden_wall), "hidden chocolate wall cannot be broken before sniffing it out")
	game.switch_character()
	game.touch_buttons["X"].pressed.emit()
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
	game.touch_buttons["Y"].pressed.emit()
	_check(game.team_weight_activated and game.team_gate == null, "Y gather hug activates the two-companion weight gate")
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
	game.touch_buttons["R"].pressed.emit()
	for _frame in 3:
		await physics_frame
	_check(game.boss_exposed_time > 0.0 and not game.banana_peel_placed, "Pochacco's banana peel makes the cream boss slip and expose its core")
	game.switch_character()
	game.dudu.global_position = Vector2(game.boss_x, game.GROUND_Y - 132.0)
	game.dudu.velocity = Vector2.ZERO
	for _frame in 2:
		await physics_frame
	game.touch_buttons["X"].pressed.emit()
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
	var has_chapter_two_button := false
	for node in game.result_overlay.find_children("*", "Button", true, false):
		if (node as Button).text == "前往第二章":
			has_chapter_two_button = true
	_check(has_chapter_two_button, "Chapter One result offers a direct continuation to Chapter Two")
	game.start_chapter_two()
	for _frame in 10:
		await process_frame
	var cloud_game := current_scene
	_check(cloud_game != null and cloud_game.chapter_index == 2, "continuing from Chapter One loads the cloud-forest chapter")
	if cloud_game == null or cloud_game.chapter_index != 2:
		_finish()
		return
	_check(cloud_game.chapter_label.text == "第二章｜棉花糖雲朵森林", "Chapter Two chapter title is localized in the HUD")
	_check(cloud_game.is_cloud_updraft(1100.0) and not cloud_game.is_cloud_updraft(1800.0), "cloud updraft zones are active only in the new chapter")
	cloud_game.touch_buttons["Y"].pressed.emit()
	_check(cloud_game.team_hug_time > 0.0, "Y performs a visible gather hug in Chapter Two")
	cloud_game.switch_character()
	cloud_game.pochacco.global_position = Vector2(cloud_game.cloud_windmill_x - 280.0, cloud_game.GROUND_Y - 27.0)
	cloud_game.pochacco.velocity = Vector2.ZERO
	cloud_game.pochacco.facing = 1.0
	cloud_game.perform_attack(cloud_game.pochacco)
	for _frame in 45:
		await physics_frame
	_check(cloud_game.cloud_windmill_active and cloud_game.cloud_gate == null, "Pochacco's returning banana rings the windmill and opens the cloud gate")
	cloud_game.pochacco.global_position = Vector2(cloud_game.plate_x, cloud_game.GROUND_Y - 27.0)
	cloud_game.pochacco.velocity = Vector2.ZERO
	for _frame in 4:
		await physics_frame
	_check(cloud_game.plate_is_held(), "Pochacco holds the cloud footplate for Dudu")
	cloud_game.dudu.global_position = Vector2(3400.0, cloud_game.GROUND_Y - 27.0)
	cloud_game.dudu.facing = 1.0
	cloud_game.dudu.velocity = Vector2.ZERO
	cloud_game.perform_attack(cloud_game.dudu)
	for _frame in 16:
		await physics_frame
	_check(cloud_game.bridge_cookie == null, "Dudu rolls through the cloud bridge gate while Pochacco holds the plate")
	cloud_game.pochacco.global_position = Vector2(4050.0, cloud_game.GROUND_Y - 27.0)
	cloud_game.pochacco.velocity = Vector2.ZERO
	cloud_game.pochacco.facing = 1.0
	cloud_game.boss_x = cloud_game.cloud_boss_x
	cloud_game.perform_attack(cloud_game.pochacco)
	for _frame in 38:
		await physics_frame
	_check(cloud_game.boss_exposed_time > 0.0, "Pochacco's boomerang reveals the cloud spirit's moon-bell core")
	cloud_game.switch_character()
	cloud_game.dudu.global_position = Vector2(cloud_game.boss_x, cloud_game.GROUND_Y - 132.0)
	cloud_game.dudu.velocity = Vector2.ZERO
	for _frame in 2:
		await physics_frame
	cloud_game.touch_buttons["X"].pressed.emit()
	for _frame in 14:
		await physics_frame
	_check(cloud_game.boss_defeated, "Dudu's ground pound sends the cloud spirit away as a gentle sparkle burst")
	cloud_game.finish_level()
	_check(cloud_game.run_over and cloud_game.result_overlay != null, "recovering the moon-honey bell completes Chapter Two")
	_finish()


func _has_joypad_button(action_name: String, button_index: int) -> bool:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for message in failures:
		push_error("[SNACKISLE_SMOKE_FAIL] " + message)
	if failures.is_empty():
		print("[SNACKISLE_SMOKE_PASS] title, zh-TW, duo switch/follow, Chapter One mechanics/result, Chapter Two windmill/cloud gate/footplate/bridge, cloud-spirit boss and moon-bell result")
	var audio := root.get_node_or_null("GameAudio")
	if audio != null and audio.has_method("stop_game"):
		audio.stop_game()
	quit(0 if failures.is_empty() else 1)
