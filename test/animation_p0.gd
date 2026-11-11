extends SceneTree

const GAME_SCENE := preload("res://scenes/game.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for _frame in 3:
		await process_frame
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	current_scene = game
	for _frame in 8:
		await process_frame
	var dudu = game.dudu
	var pochacco = game.pochacco
	_check(dudu != null and pochacco != null, "both buddies spawn for P0 animation test")
	if dudu != null and pochacco != null:
		_check(game.pose_frames_for(true, "idle").size() == 4, "Dudu idle animation has four loop frames")
		_check(game.pose_frames_for(true, "run").size() == 4, "Dudu run animation has four loop frames")
		_check(game.pose_frames_for(false, "idle").size() == 4, "Pochacco idle animation has four loop frames")
		_check(game.pose_frames_for(false, "run").size() == 4, "Pochacco run animation has four loop frames")

		dudu.velocity = Vector2.ZERO
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_idle.png", "Dudu starts on idle frame 0")
		dudu._process(0.21)
		_check(_frame_name(dudu) == "dudu_idle_01.png", "Dudu idle cycle advances to the next frame")
		dudu.velocity.x = 100.0
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_run.png", "Dudu starts its run cycle when moving")
		dudu._process(0.11)
		_check(_frame_name(dudu) == "dudu_run_01.png", "Dudu run cycle advances at its configured rate")
		dudu.velocity = Vector2.ZERO
		dudu.velocity.y = -100.0
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_jump.png", "Dudu keeps the jump pose while airborne")
		dudu.velocity.y = 0.0
		dudu.roll_time = 0.2
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_roll.png", "Dudu switches to roll pose during dash")
		dudu.roll_time = 0.0
		dudu.hurt_pose_time = 0.0
		dudu.ground_pounding = true
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_pound_01.png", "Dudu shows the descending butt-stomp pose")
		dudu.ground_pounding = false
		dudu.pound_recovery_time = 0.28
		dudu.active_pose = ""
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_pound_02.png", "Dudu shows impact pose when the ground-pound lands")
		dudu._process(0.14)
		_check(_frame_name(dudu) == "dudu_pound_03.png", "Dudu advances to the ground-pound recovery pose")
		dudu.pound_recovery_time = 0.0
		dudu.receive_soft_hit()
		dudu._process(0.0)
		_check(_frame_name(dudu) == "dudu_hurt.png", "Dudu switches to hurt pose after damage")

		pochacco.velocity = Vector2.ZERO
		pochacco.hurt_pose_time = 0.0
		pochacco._process(0.0)
		_check(_frame_name(pochacco) == "pochacco_idle.png", "Pochacco starts on idle frame 0")
		pochacco._process(0.21)
		_check(_frame_name(pochacco) == "pochacco_idle_01.png", "Pochacco idle cycle advances to the next frame")
		pochacco.velocity.x = 100.0
		pochacco._process(0.0)
		_check(_frame_name(pochacco) == "pochacco_run.png", "Pochacco starts its run cycle when moving")
		pochacco._process(0.11)
		_check(_frame_name(pochacco) == "pochacco_run_01.png", "Pochacco run cycle advances at its configured rate")
		pochacco.velocity = Vector2.ZERO
		pochacco.velocity.y = -100.0
		pochacco._process(0.0)
		_check(_frame_name(pochacco) == "pochacco_jump.png", "Pochacco keeps the jump pose while airborne")
		pochacco.velocity.y = 0.0
		pochacco.action_pose_time = 0.2
		pochacco._process(0.0)
		_check(_frame_name(pochacco) == "pochacco_boomerang.png", "Pochacco switches to boomerang pose during attack")
		pochacco.action_pose_time = 0.0
		pochacco.receive_soft_hit()
		pochacco._process(0.0)
		_check(_frame_name(pochacco) == "pochacco_hurt.png", "Pochacco switches to hurt pose after damage")

		game.finish_level()
		dudu._process(0.0)
		pochacco._process(0.0)
		_check(dudu.victory_pose and _frame_name(dudu) == "dudu_victory.png", "finishing a level triggers Dudu victory pose")
		_check(pochacco.victory_pose and _frame_name(pochacco) == "pochacco_victory.png", "finishing a level triggers Pochacco victory pose")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("[ANIMATION_P0_PASS] idle/run loops, ground-pound, victory, and existing poses")
	quit(1 if not failures.is_empty() else 0)

func _frame_name(buddy) -> String:
	if buddy == null or buddy.sprite == null or buddy.sprite.texture == null:
		return ""
	return buddy.sprite.texture.resource_path.get_file()

func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures.append(message)
	push_error(message)
