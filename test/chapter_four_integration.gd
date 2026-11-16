extends SceneTree

const GAME_SCRIPT := preload("res://scripts/snackisle_game.gd")

func _initialize() -> void:
	set_meta("snackisle_chapter", 4)
	call_deferred("_run")

func _run() -> void:
	var game = GAME_SCRIPT.new()
	root.add_child(game)
	await process_frame
	assert(game.chapter_index == 4, "game should accept chapter four selection")
	assert(is_instance_valid(game.chapter_four), "chapter four should build its mechanics controller")
	assert(is_instance_valid(game.chapter_four_gate), "echo puzzle should begin behind a gate")
	assert(is_instance_valid(game.chapter_four_mirror_gate), "prism puzzle should begin behind a gate")

	var controller = game.chapter_four
	controller.begin_echo()
	controller.advance(2.5)
	assert(controller.echo_state == controller.EchoState.INPUT, "echo cue should become playable")
	assert(controller.input_tone(0), "first tone should be accepted")
	assert(controller.input_tone(2), "second tone should be accepted")
	assert(controller.input_tone(1), "third tone should solve the echo")
	await process_frame
	assert(game.chapter_four_gate == null, "solving echo should open its coral gate")
	assert(controller.rotate_mirror(0), "echo solution should enable mirror interaction")
	assert(not controller.prism_lit, "one aligned mirror is not enough")
	assert(controller.rotate_mirror(1), "second mirror should rotate")
	assert(controller.prism_lit, "aligned mirrors should reach the receiver")
	await process_frame
	assert(game.chapter_four_mirror_gate == null, "receiver activation should open the glass reef gate")
	print("CHAPTER_FOUR_INTEGRATION_PASS")
	quit(0)
