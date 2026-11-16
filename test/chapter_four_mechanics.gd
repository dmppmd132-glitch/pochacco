extends SceneTree

const CHAPTER_FOUR_SCRIPT = preload("res://scripts/chapter_four.gd")

func _initialize() -> void:
	var controller = CHAPTER_FOUR_SCRIPT.new()
	root.add_child(controller)
	_expect(not controller.rotate_mirror(0), "mirror controls stay locked until echo is solved")
	_expect(controller.begin_echo(), "echo sequence can start")
	_expect(controller.echo_state == controller.EchoState.LISTENING, "echo begins with a listen phase")
	controller.advance(2.4)
	_expect(controller.echo_state == controller.EchoState.INPUT, "three visual beats transition to input")
	_expect(controller.input_tone(0), "first expected tone accepted")
	_expect(not controller.input_tone(1), "wrong tone is rejected")
	_expect(controller.echo_state == controller.EchoState.RETRY, "wrong tone enters retry state")
	controller.advance(controller.ECHO_RETRY_SECONDS)
	_expect(controller.echo_state == controller.EchoState.LISTENING, "retry replays the full sequence")
	controller.advance(2.4)
	_expect(controller.echo_state == controller.EchoState.INPUT, "replay returns to input")
	_expect(controller.input_tone(0), "retry accepts first tone")
	_expect(controller.input_tone(2), "retry accepts second tone")
	_expect(controller.input_tone(1), "retry accepts third tone")
	_expect(controller.echo_solved_flag, "correct three-tone sequence solves echo")
	_expect(controller.rotate_mirror(0), "first mirror rotates")
	_expect(not controller.prism_lit, "partial mirror alignment does not solve path")
	_expect(controller.rotate_mirror(1), "second mirror rotates")
	_expect(controller.prism_lit, "two aligned mirrors connect receiver")

	var focus_test = CHAPTER_FOUR_SCRIPT.new()
	root.add_child(focus_test)
	focus_test.begin_echo()
	focus_test.advance(2.4)
	focus_test.input_tone(0)
	focus_test.cancel_echo_for_focus_loss()
	_expect(focus_test.echo_state == focus_test.EchoState.IDLE, "focus loss clears current echo input")
	_expect(focus_test.echo_input_index == 0, "focus loss clears partial sequence")
	_expect(not focus_test.echo_solved_flag, "focus loss does not falsely solve echo")

	var mirror_cells: Array[Vector2i] = [Vector2i(2, 2), Vector2i(2, 0)]
	for first in 4:
		for second in 4:
			var trace: Dictionary = controller.trace_prism(mirror_cells, [first, second])
			var expected_lit := first % 2 == 0 and second % 2 == 0
			_expect(bool(trace["lit"]) == expected_lit, "mirror configuration %d,%d has deterministic receiver result" % [first, second])
	var bounded: Dictionary = controller.trace_prism(mirror_cells, [0, 0], 2)
	_expect(not bounded["lit"], "short path limit cannot report a false receiver hit")
	_expect(not controller.trace_prism([], [], 24)["lit"], "straight ray does not reach off-axis receiver")

	print("[CHAPTER_FOUR_MECHANICS_PASS] Echo state, recovery, focus reset, 16 mirror configurations and ray bounds passed.")
	quit(0)

func _expect(condition: bool, label: String) -> void:
	if not condition:
		push_error("[CHAPTER_FOUR_MECHANICS_FAIL] " + label)
		quit(1)
