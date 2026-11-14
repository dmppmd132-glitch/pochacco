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
	_expect(chapter.steam_vents.size() == 3, "chapter builds three independent steam vents")
	_expect(chapter.steam_hint(2970.0).contains("預熱"), "sniff hint reports the nearest vent phase")
	chapter.on_ground_pound(2970.0)
	_expect(chapter.steam_vents[0].is_safe_window(), "ground-pound dispatch suppresses the nearby valve")
	_expect(game.last_toast.contains("2.4 秒"), "valve suppression reports its safe duration")
	_expect(not chapter.suppress_vent_near(1000.0), "distant ground-pound does not suppress a valve")
	print("[CHAPTER_THREE_MECHANICS_PASS] Vent cycle, staggered route setup, sniff hint and valve suppression passed.")
	quit(0)

func _expect(condition: bool, label: String) -> void:
	if not condition:
		push_error("[CHAPTER_THREE_MECHANICS_FAIL] " + label)
		quit(1)
