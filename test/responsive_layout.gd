extends SceneTree

const TITLE_SCENE: PackedScene = preload("res://scenes/title_screen.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")
const VIEWPORT_SIZES := [
	Vector2i(640, 360),
	Vector2i(800, 450),
	Vector2i(960, 540),
	Vector2i(1280, 720),
	Vector2i(1680, 720),
	Vector2i(1920, 1080),
]

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var store := root.get_node("TuningStore")
	var original_mode: float = store.get_value("display_mode")
	for display_mode in [0.0, 1.0]:
		store.set_value("display_mode", display_mode)
		for physical_size: Vector2i in VIEWPORT_SIZES:
			root.size = physical_size
			await _settle()
			_check_viewport(physical_size, int(display_mode))
			await _check_title(physical_size)
			await _check_game(physical_size)
	store.set_value("display_mode", original_mode)
	var audio := root.get_node_or_null("GameAudio")
	if audio != null:
		audio.stop_game()
	if failures.is_empty():
		print("[SNACKISLE_RESPONSIVE_PASS] 16:9 PWA, title, notebook HUD and touch targets across landscape viewport sizes")
	for message: String in failures:
		push_error("[SNACKISLE_RESPONSIVE_FAIL] " + message)
	quit(0 if failures.is_empty() else 1)


func _settle() -> void:
	for _frame in 3:
		await process_frame


func _check_viewport(physical_size: Vector2i, display_mode: int) -> void:
	var visible_size: Vector2 = root.get_visible_rect().size
	var physical_aspect := float(physical_size.x) / float(physical_size.y)
	var expected_aspect := 16.0 / 9.0 if display_mode == 0 else clampf(physical_aspect, 1.0, 16.0 / 6.0)
	if visible_size.y <= 0.0 or absf(visible_size.x / visible_size.y - expected_aspect) > 0.015:
		failures.append("logical viewport aspect mismatched at %s: %s" % [physical_size, visible_size])
	if root.content_scale_aspect != Window.CONTENT_SCALE_ASPECT_KEEP:
		failures.append("uniform contain scaling not active at %s" % physical_size)
	var design := Vector2(1280.0, 1280.0 / expected_aspect)
	if expected_aspect >= 1280.0 / 720.0:
		design = Vector2(720.0 * expected_aspect, 720.0)
	var scale := minf(1.0, minf(float(physical_size.x) / design.x, float(physical_size.y) / design.y))
	var expected_size := Vector2i(roundi(design.x * scale), roundi(design.y * scale))
	if root.content_scale_size != expected_size:
		failures.append("viewport policy returned %s instead of %s at %s" % [root.content_scale_size, expected_size, physical_size])
	var transform := root.get_final_transform()
	if absf(transform.x.length() - transform.y.length()) > 0.002:
		failures.append("non-uniform stretch detected at %s" % physical_size)


func _check_title(physical_size: Vector2i) -> void:
	var title := TITLE_SCENE.instantiate() as Control
	root.add_child(title)
	await _settle()
	var viewport_size: Vector2 = title.get_viewport_rect().size
	var panel := title.find_child("DiaryCard", true, false) as Control
	var start := title.find_child("StartAdventure", true, false) as Control
	var chapter_two := title.find_child("StartChapterTwo", true, false) as Control
	_check_rect(panel, viewport_size, "title panel", physical_size)
	_check_rect(start, viewport_size, "start button", physical_size)
	_check_rect(chapter_two, viewport_size, "chapter two button", physical_size)
	if start != null and (start.size.x < 190.0 or start.size.y < 40.0):
		failures.append("start button too small at %s: %s" % [physical_size, start.size])
	if chapter_two != null and (chapter_two.size.x < 190.0 or chapter_two.size.y < 40.0):
		failures.append("chapter two button too small at %s: %s" % [physical_size, chapter_two.size])
	title.queue_free()
	await process_frame


func _check_game(physical_size: Vector2i) -> void:
	var game := GAME_SCENE.instantiate() as Node2D
	root.add_child(game)
	await _settle()
	var viewport_size: Vector2 = game.get_viewport_rect().size
	for node_name in ["NotebookHUD", "Objective", "PauseButton", "TouchJoystick", "TouchA", "TouchB", "TouchX", "TouchY", "TouchL", "TouchR"]:
		var control := game.find_child(node_name, true, false) as Control
		_check_rect(control, viewport_size, node_name, physical_size)
		if node_name == "TouchJoystick" and control != null and (control.size.x < 112.0 or control.size.y < 112.0):
			failures.append("virtual joystick touch target too small at %s: %s" % [physical_size, control.size])
		if node_name in ["TouchA", "TouchB", "TouchX", "TouchY", "TouchL", "TouchR"] and control != null and (control.size.x < 42.0 or control.size.y < 42.0):
			failures.append("gamepad-style touch target too small at %s for %s: %s" % [physical_size, node_name, control.size])
	var touch_controls := game.find_child("PwaTouchControls", true, false) as Control
	if touch_controls == null:
		failures.append("PWA touch control layer is missing at %s" % physical_size)
	elif viewport_size.x < 900.0 and not touch_controls.visible:
		failures.append("touch controls should appear at landscape viewport %s" % physical_size)
	var inventory := game.find_child("InventoryCounts", true, false) as Control
	_check_rect(inventory, viewport_size, "backpack counter row", physical_size)
	game.queue_free()
	await process_frame


func _check_rect(control: Control, viewport_size: Vector2, label: String, physical_size: Vector2i) -> void:
	if control == null:
		failures.append("%s is missing at %s" % [label, physical_size])
		return
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0 or rect.position.x < -0.5 or rect.position.y < -0.5 or rect.end.x > viewport_size.x + 0.5 or rect.end.y > viewport_size.y + 0.5:
		failures.append("%s outside visible canvas at %s: %s / %s" % [label, physical_size, rect, viewport_size])
