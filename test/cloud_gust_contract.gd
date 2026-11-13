extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")
const GUST_POINT := Vector2(2940.0, 500.0)
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	for action_name in ["move_left", "move_right"]:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
	for _frame in 2:
		await process_frame
	var game = GAME_SCENE.instantiate()
	root.add_child(game)
	current_scene = game
	for _frame in 4:
		await physics_frame

	var saved_time: float = game.time_alive
	game.chapter_index = 1
	game.time_alive = 0.2
	_check(is_zero_approx(game.cloud_gust_force(GUST_POINT)), "gust must be disabled outside Chapter Two")

	game.chapter_index = 2
	_check(game.cloud_gust_force(GUST_POINT) < 0.0, "gust should push west during its active pulse")
	for point in [Vector2(2840.0, 500.0), Vector2(3050.0, 500.0), Vector2(2940.0, 390.0), Vector2(2940.0, 610.0)]:
		_check(game.cloud_gust_force(point) < 0.0, "gust zone should include its documented boundary: %s" % point)
	for point in [Vector2(2839.0, 500.0), Vector2(3051.0, 500.0), Vector2(2940.0, 389.0), Vector2(2940.0, 611.0)]:
		_check(is_zero_approx(game.cloud_gust_force(point)), "gust should not leak outside its boundary: %s" % point)

	game.time_alive = 1.25
	_check(is_zero_approx(game.cloud_gust_force(GUST_POINT)), "gust should stop at the end of its active pulse")
	game.time_alive = 2.0
	_check(is_zero_approx(game.cloud_gust_force(GUST_POINT)), "gust should provide a calm crossing window")
	game.time_alive = 3.79
	_check(is_zero_approx(game.cloud_gust_force(GUST_POINT)), "gust should remain calm before the next cycle")
	game.time_alive = 3.8
	_check(game.cloud_gust_force(GUST_POINT) < 0.0, "gust should restart at the next cycle boundary")

	game.time_alive = 0.2
	game.dudu.global_position = Vector2(2940.0, game.GROUND_Y - 27.0)
	game.dudu.velocity = Vector2.ZERO
	for action_name in ["move_left", "move_right"]:
		if InputMap.has_action(action_name):
			Input.action_release(action_name)
	for _frame in 2:
		await physics_frame
	var x_before_gust: float = game.dudu.global_position.x
	for _frame in 8:
		await physics_frame
	_check(game.dudu.global_position.x < x_before_gust - 12.0, "active gust should physically push a stationary Buddy west")

	game.time_alive = saved_time
	game.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("[CLOUD_GUST_CONTRACT_PASS] All gust boundaries, timing phases, chapter gating, and physical push checks passed.")
		quit(0)
		return
	for message in failures:
		push_error("[CLOUD_GUST_CONTRACT_FAIL] " + message)
	quit(1)
