extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for action_name in ["move_left", "move_right", "jump"]:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
	for _frame in 3:
		await process_frame
	var game = GAME_SCENE.instantiate()
	root.add_child(game)
	current_scene = game
	for _frame in 4:
		await physics_frame

	var constants: Dictionary = game.get_script().get_script_constant_map()
	var ground_y := float(constants["GROUND_Y"])
	var platform_top := float(constants["START_PLATFORM_TOP"])
	var jump_speed := float(constants["DUDU_JUMP_SPEED"])
	var gravity := float(constants["GRAVITY"])
	_check(jump_speed * jump_speed / (2.0 * gravity) >= ground_y - platform_top + 16.0,
		"Dudu jump arc must clear the opening chiffon platform with safe margin")

	game.dudu.global_position = Vector2(420.0, ground_y - 27.0)
	game.dudu.velocity = Vector2.ZERO
	game.pochacco.global_position = Vector2(100.0, ground_y - 27.0)
	game.pochacco.velocity = Vector2.ZERO
	for _frame in 2:
		await physics_frame
	var stars_before: int = game.star_candies
	var bounce_seen := false
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for _frame in 90:
		await physics_frame
		if game.dudu.velocity.y <= -680.0:
			bounce_seen = true
	Input.action_release("move_right")

	_check(bounce_seen, "opening chiffon platform must apply a trampoline bounce")
	_check(game.dudu.is_on_floor() and game.dudu.global_position.x >= 717.0 and game.dudu.global_position.x <= 940.0,
		"trampoline route must land Dudu on the next biscuit platform")
	_check(game.star_candies > stars_before, "opening platform route must collect its route star candy")
	game.queue_free()
	await process_frame
	_finish()

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("[PLATFORM_ROUTE_CONTRACT_PASS] Opening chiffon reachability, bounce, biscuit landing and star pickup passed.")
		quit(0)
		return
	for message in failures:
		push_error("[PLATFORM_ROUTE_CONTRACT_FAIL] " + message)
	quit(1)
