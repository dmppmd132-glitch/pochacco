extends SceneTree

const BOSS_SCRIPT := preload("res://scripts/tidal_jellyfish_boss.gd")


class BossGameStub extends Node:
	var toast_messages: Array[String] = []
	var victory_count := 0
	var core_hit_count := 0
	var state_changes: Array[int] = []

	func show_toast(message: String) -> void:
		toast_messages.append(message)

	func on_tidal_jellyfish_state_changed(_boss, state: int) -> void:
		state_changes.append(state)

	func on_tidal_jellyfish_core_hit(_boss, _hits: int, _limit: int) -> void:
		core_hit_count += 1

	func on_tidal_jellyfish_defeated(_boss) -> void:
		victory_count += 1


var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var fake_game := BossGameStub.new()
	root.add_child(fake_game)
	var boss = BOSS_SCRIPT.new()
	root.add_child(boss)
	boss.setup(fake_game, Vector2(4550.0, 550.0))
	boss.activate()
	_expect(boss.state == boss.State.TELEGRAPH_RIPPLE, "phase one begins with a ground-ripple telegraph")
	boss.advance_phase(boss.TELEGRAPH_SECONDS + 0.02)
	_expect(boss.state == boss.State.RIPPLE_ACTIVE, "phase-one warning precedes the active ripple")
	boss.advance_phase(2.0)
	_expect(boss.state == boss.State.MIRROR_PUZZLE, "phase one becomes a readable mirror puzzle after the ripple")
	_expect(boss.on_ground_pound(boss.weak_point_position(), true), "a premature stomp is safely consumed")
	_expect(boss.core_hits == 0, "a stomp before core exposure cannot damage the boss")
	_expect(_hit_mirror(boss, 0, 101), "first mirror interaction is accepted")
	_expect(not boss._mirrors_aligned(), "one mirror interaction cannot expose the phase-one core")
	_expect(not boss.on_boomerang_hit(boss.mirror_world_position(0), 101), "the same returning projectile cannot rotate a mirror twice")
	_expect(_hit_mirror(boss, 0, 102), "second distinct projectile is accepted")
	_expect(_hit_mirror(boss, 0, 103), "third distinct projectile aligns the mirror")
	_expect(boss.state == boss.State.CORE_EXPOSED, "aligned phase-one mirror exposes the core")
	_expect(boss.on_ground_pound(boss.weak_point_position(), false), "Pochacco stomp is consumed but does not damage the core")
	_expect(boss.core_hits == 0, "wrong character does not count as a core hit")
	_expect(boss.on_ground_pound(boss.weak_point_position(), true), "Dudu stomp damages the exposed core once")
	_expect(boss.core_hits == 1 and boss.state == boss.State.HIT_RECOVERY, "first valid hit enters recovery and preserves 1/3")
	_expect(boss.on_ground_pound(boss.weak_point_position(), true) and boss.core_hits == 1, "repeated stomp during recovery is ignored")
	boss.advance_phase(boss.HIT_RECOVERY_SECONDS + 0.02)
	_expect(boss.phase == 2 and boss.state == boss.State.TELEGRAPH_TIDE, "second phase starts with a tide telegraph")
	boss.advance_phase(boss.TELEGRAPH_SECONDS + 0.02)
	_expect(boss.state == boss.State.TIDE_ACTIVE, "tide attack begins only after its warning")
	_expect(boss.tide_force(Vector2(4550, 500)) != 0.0, "active tide pushes in a fixed direction")
	_expect(is_zero_approx(boss.tide_force(Vector2(4328, 500))), "raised edge refuges are protected from tide force")
	boss.advance_phase(2.1)
	_expect(boss.state == boss.State.MIRROR_PUZZLE, "tide ends before phase-two mirror operations")
	_expect(_hit_mirror(boss, 0, 201), "phase-two left mirror first turn is accepted")
	_expect(_hit_mirror(boss, 0, 202), "phase-two left mirror reaches its target")
	_expect(boss.on_ground_pound(boss.anchor_position(), true), "Dudu can lock the central anchor for six seconds")
	_expect(boss.interact_mirror_near(boss.mirror_world_position(1)), "right mirror can be rotated after anchor setup")
	_expect(boss.state == boss.State.CORE_EXPOSED, "two-mirror path exposes phase-two core")
	boss.on_ground_pound(boss.weak_point_position(), true)
	_expect(boss.core_hits == 2 and boss.state == boss.State.HIT_RECOVERY, "second valid hit advances to 2/3")
	boss.advance_phase(boss.HIT_RECOVERY_SECONDS + 0.02)
	_expect(boss.phase == 3 and boss.state == boss.State.TELEGRAPH_RIPPLE, "third phase begins after protected recovery")
	boss.advance_phase(boss.TELEGRAPH_SECONDS + 0.02)
	boss.advance_phase(2.0)
	_expect(boss.state == boss.State.ECHO_PLAYBACK, "third-phase two-beat echo starts only after the attack")
	boss.advance_phase(boss.ECHO_BEAT_SECONDS * 2.0 + 0.02)
	_expect(boss.state == boss.State.ECHO_INPUT, "two-beat echo playback transitions to input")
	_expect(boss.on_boomerang_hit(boss.echo_bell_position(1), 301), "wrong echo note is consumed safely")
	_expect(boss.state == boss.State.ECHO_RETRY and boss.core_hits == 2, "wrong note restarts the echo without losing health or core hits")
	boss.advance_phase(boss.ECHO_RETRY_SECONDS + 0.02)
	boss.advance_phase(boss.ECHO_BEAT_SECONDS * 2.0 + 0.02)
	_expect(boss.state == boss.State.ECHO_INPUT, "echo retry replays the complete sequence")
	_expect(boss.on_boomerang_hit(boss.echo_bell_position(0), 302), "first correct echo beat is accepted")
	_expect(boss.on_boomerang_hit(boss.echo_bell_position(1), 303), "second correct echo beat advances to the mirror")
	_expect(boss.state == boss.State.MIRROR_PUZZLE, "correct echo opens the familiar phase-three mirror")
	_expect(_hit_mirror(boss, 0, 304), "phase-three mirror can be aligned with one action")
	_expect(boss.state == boss.State.CORE_EXPOSED, "phase-three mirror exposes the final core")
	boss.on_ground_pound(boss.weak_point_position(), true)
	_expect(boss.core_hits == boss.REQUIRED_CORE_HITS and boss.state == boss.State.DEFEATED, "exactly three valid core hits defeat the boss")
	_expect(fake_game.victory_count == 1, "the final hit emits the victory callback exactly once")
	boss.advance_phase(10.0)
	_expect(fake_game.victory_count == 1, "defeated boss never emits a second victory")
	_expect(fake_game.core_hit_count == 2, "only the two non-final damage callbacks are emitted")
	boss.reset_after_full_death()
	_expect(boss.core_hits == 0 and boss.phase == 1 and boss.state == boss.State.TELEGRAPH_RIPPLE, "full death resets the fight to phase one")

	for failure in failures:
		push_error("[CHAPTER_FOUR_BOSS_FAIL] " + failure)
	if failures.is_empty():
		print("[CHAPTER_FOUR_BOSS_PASS] telegraphs, fixed tide, echo retry, mirror gating, hit de-duplication, three-hit victory and death reset")
	quit(0 if failures.is_empty() else 1)


func _hit_mirror(boss, index: int, shot_id: int) -> bool:
	return boss.on_boomerang_hit(boss.mirror_world_position(index), shot_id)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
