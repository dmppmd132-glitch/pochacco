extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	set_meta("snackisle_chapter", 3)
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for _frame in 3:
		await process_frame
	var game = GAME_SCENE.instantiate()
	root.add_child(game)
	current_scene = game
	for _frame in 6:
		await physics_frame

	_check(game.chapter_index == 3 and game.chapter_three.gears.size() == 4, "the actual Chapter Three scene loads all four moving gears")
	var chapter = game.chapter_three
	var low = chapter._gear_by_id("工坊齒輪")
	var high = chapter._gear_by_id("工坊高位齒輪")
	_check(low is AnimatableBody2D and low.sync_to_physics, "workshop carrier is the real physics-synchronized AnimatableBody2D")
	game.switch_character()
	_check(game.touch_buttons["B"].text.contains("敲鈴"), "Pochacco's chapter-three touch action clearly labels the bell-reversal move")
	_check(game.touch_buttons["X"].text.contains("嗅嗅"), "Pochacco retains the sniff action label for route hints")
	_check(game.touch_buttons["B"].size.x >= 48.0 and game.touch_buttons["X"].size.y >= 48.0, "chapter-three touch action targets meet the 48px minimum")
	game.switch_character()
	_check(game.touch_buttons["X"].text.contains("煞車"), "Dudu's chapter-three touch action clearly labels gear braking")

	# Put the real controlled Buddy at the center of the real moving carrier.
	game.pochacco.set_physics_process(false)
	game.dudu.controlled = true
	game.dudu.global_position = Vector2(low.global_position.x, low.global_position.y - 42.0)
	game.dudu.velocity = Vector2.ZERO
	for _frame in 5:
		await physics_frame
	_check(game.dudu.is_on_floor(), "Dudu can land on the moving workshop gear")
	var rider_start: float = game.dudu.global_position.x
	var carrier_start: float = low.global_position.x
	for _frame in 18:
		await physics_frame
	var rider_delta: float = game.dudu.global_position.x - rider_start
	var carrier_delta: float = low.global_position.x - carrier_start
	_check(carrier_delta > 20.0, "the workshop gear advances during real physics frames")
	_check(rider_delta > 12.0 and absf(rider_delta - carrier_delta) <= 12.0, "the real character is carried with the AnimatableBody2D without drifting off")

	# A rider near the platform edge must remain supported while the gear brakes.
	game.dudu.global_position.x = low.global_position.x + 118.0
	for _frame in 3:
		await physics_frame
	_check(game.dudu.is_on_floor(), "the passenger remains supported near the platform edge")
	var brake_start: Vector2 = low.global_position
	_check(chapter.brake_near(2670.0), "the workshop brake interaction is reachable in the actual route controller")
	_check(is_equal_approx(low.brake_remaining, 6.5), "first in-route brake presents the 6.5-second tutorial window")
	_check(game.objective_label.text.contains("6.5 秒"), "the objective reports the active tutorial brake duration")
	for _frame in 6:
		await physics_frame
	_check(low.global_position.is_equal_approx(brake_start), "the actual workshop carrier remains docked during the tutorial brake")
	low.advance_motion(6.5)
	_check(not low.is_braked(), "the first brake releases the actual gear after its tutorial countdown")
	await process_frame
	await process_frame
	_check(not game.objective_label.text.contains("齒輪暫停了"), "the objective clears when the last active brake expires")

	# Exercise the second, opposite-direction carrier and its standard brake.
	game.dudu.global_position = Vector2(high.global_position.x, high.global_position.y - 42.0)
	game.dudu.velocity = Vector2.ZERO
	for _frame in 5:
		await physics_frame
	_check(game.dudu.is_on_floor(), "Dudu can land on the real upper workshop gear")
	var high_start: float = high.global_position.x
	for _frame in 12:
		await physics_frame
	_check(high.global_position.x < high_start, "the linked upper gear moves in the opposite direction")
	_check(chapter.brake_near(2450.0), "the upper gear's dedicated brake works in the real controller")
	_check(is_equal_approx(high.brake_remaining, 5.0), "subsequent route brakes use the standard five seconds")
	_check(game.objective_label.text.contains("5 秒"), "the objective reports the standard duration on later brakes")
	var low_before_upper_brake: float = low.global_position.x
	for _frame in 10:
		await physics_frame
	_check(low.global_position.x != low_before_upper_brake, "braking the upper carrier does not freeze the lower gear")
	_check(game.dudu.is_on_floor(), "the rider stays supported during upper-gear braking")

	# Trigger the real checkpoint and fall recovery handlers for the high landing.
	game.dudu.global_position = Vector2(2300.0, 300.0)
	game.on_buddy_moved_checkpoint_check()
	_check(game.checkpoint_x == 2240.0, "crossing the high-route landing activates its real recovery checkpoint")
	game.dudu.global_position = Vector2(2300.0, 830.0)
	game.fall_to_safety(game.dudu)
	_check(is_equal_approx(game.dudu.global_position.x, 2240.0), "a fall returns Dudu to the activated high-route checkpoint")
	_check(game.dudu.global_position.y < game.GROUND_Y, "checkpoint recovery places the character above safe ground")

	if failures.is_empty():
		print("[CHAPTER_THREE_ROUTE_SMOKE_PASS] Real scene gear riding, edge support, tutorial/standard brakes, independent carrier motion and checkpoint recovery passed.")
	else:
		for failure in failures:
			push_error("[CHAPTER_THREE_ROUTE_SMOKE_FAIL] " + failure)
	var audio := root.get_node_or_null("GameAudio")
	if audio != null and audio.has_method("stop_game"):
		audio.stop_game()
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
