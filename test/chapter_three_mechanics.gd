extends SceneTree

const VENT_SCRIPT = preload("res://scripts/steam_vent.gd")
const CHAPTER_SCRIPT = preload("res://scripts/chapter_three.gd")

class GameStub extends Node:
	const GROUND_Y := 610.0
	const GAME_FONT: Font = null
	var last_toast := ""

	func show_toast(message: String) -> void:
		last_toast = message

	func _update_objective() -> void:
		pass

func _initialize() -> void:
	var vent = VENT_SCRIPT.new()
	vent.setup(null, "測試噴口", Vector2.ZERO, Vector2.ZERO, 0.0)
	root.add_child(vent)
	_expect(vent.phase_name() == "preheat", "vent starts in preheat")
	vent.advance_phase(0.8)
	_expect(vent.phase_name() == "erupting", "0.8s preheat transitions to eruption")
	vent.advance_phase(0.9)
	_expect(vent.phase_name() == "cooldown", "0.9s eruption transitions to cooldown")
	_expect(vent.suppress_for(2.4), "valve suppression accepted")
	_expect(vent.is_safe_window(), "suppressed valve is safe")
	vent.advance_phase(2.4)
	_expect(vent.phase_name() == "cooldown", "valve resumes in a safe phase")

	var game := GameStub.new()
	var chapter = CHAPTER_SCRIPT.new()
	root.add_child(game)
	root.add_child(chapter)
	chapter.setup(game)
	_expect(chapter.gears.size() == 4, "data-driven specs build the workshop gear pair")
	_expect(chapter.interaction_nodes.size() == 5, "data-driven specs build dedicated workshop controls")
	var square = chapter._gear_by_id("廣場齒輪")
	var workshop = chapter._gear_by_id("工坊齒輪")
	var workshop_high = chapter._gear_by_id("工坊高位齒輪")
	var tower = chapter._gear_by_id("鐘樓外環")
	var square_direction: float = square.direction
	_expect(chapter.on_boomerang_hit(Vector2(1090.0, 0.0)), "square bell routes by interaction node")
	_expect(square.direction == -square_direction, "square bell reverses only the square gear")
	_expect(workshop.direction == 1.0 and tower.direction == 1.0, "square reversal does not mutate other gears")
	_expect(chapter.on_ground_pound(Vector2(2670.0, 593.0), true), "workshop brake routes by interaction node")
	_expect(workshop.is_braked() and is_equal_approx(workshop.brake_remaining, 6.5), "first tutorial brake holds for 6.5 seconds")
	_expect(game.last_toast.contains("6.5 秒"), "first brake explains its tutorial grace window")
	_expect(not square.is_braked() and not tower.is_braked(), "workshop brake does not freeze other gears")
	workshop.advance_motion(6.5)
	_expect(not workshop.is_braked(), "low gear brake countdown restores the low gear")
	_expect(chapter.on_ground_pound(Vector2(2450.0, 300.0), true), "second brake targets the nearby upper workshop gear")
	_expect(is_equal_approx(workshop_high.brake_remaining, 5.0), "later brakes retain the standard five-second duration")
	workshop_high.advance_motion(5.0)
	_expect(workshop.linked_group_id == workshop_high.linked_group_id, "workshop gears share a linked group")
	_expect(workshop.direction == -workshop_high.direction, "workshop gears start in opposite directions")
	square.position.x = square.left_x + square.speed * 0.5
	square.turn_warning_announced = false
	square.turn_warning_active = false
	square.advance_motion(0.01)
	_expect(square.turn_warning_active, "gear signals a visible turn warning within the half-second window")
	_expect(square.turn_warning_announced, "one turn warning is emitted per automatic direction change")
	square.advance_motion(0.5)
	_expect(square.direction == 1.0 and not square.turn_warning_active, "turn preview clears after the gear automatically reverses")
	_expect(chapter.on_boomerang_hit(Vector2(1500.0, 0.0)), "workshop bell routes to the linked group")
	_expect(workshop.direction == -workshop_high.direction, "group reversal preserves opposite directions")
	_expect(chapter.on_ground_pound(Vector2(2450.0, 300.0), true), "high gear brake selects the nearest gear")
	_expect(workshop_high.is_braked() and not workshop.is_braked(), "high gear brake does not freeze low gear")
	workshop.advance_motion(0.25)
	workshop_high.advance_motion(0.25)
	_expect(workshop.motion_delta.length() > 0.0 and workshop_high.motion_delta == Vector2.ZERO, "carrier motion continues beside a braked gear")
	workshop_high.advance_motion(5.0)
	_expect(not workshop_high.is_braked(), "brake countdown restores the high gear")
	var tower_direction: float = tower.direction
	_expect(chapter.on_boomerang_hit(Vector2(3920.0, 0.0)), "tower bell has a dedicated control node")
	_expect(tower.direction == -tower_direction, "tower bell reverses the tower gear")
	_expect(chapter.steam_vents.size() == 3, "chapter builds three independent steam vents")
	_expect(chapter.steam_hint(2970.0).contains("預熱"), "sniff hint reports the nearest vent phase")
	chapter.on_ground_pound(Vector2(2970.0, 593.0), true)
	_expect(chapter.steam_vents[0].is_safe_window(), "ground-pound dispatch suppresses the nearby valve")
	_expect(game.last_toast.contains("2.4 秒"), "valve suppression reports its safe duration")
	_expect(not chapter.suppress_vent_near(1000.0), "distant ground-pound does not suppress a valve")
	print("[CHAPTER_THREE_MECHANICS_PASS] Dual-gear group reversal, per-gear braking, carrier motion and vent cycle passed.")
	quit(0)

func _expect(condition: bool, label: String) -> void:
	if not condition:
		push_error("[CHAPTER_THREE_MECHANICS_FAIL] " + label)
		quit(1)
