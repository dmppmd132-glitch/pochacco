extends SceneTree

const GEAR_GUARDIAN_SCRIPT := preload("res://scripts/gear_guardian.gd")


class GuardianHarness extends Node:
	var run_over := false
	var state_changes: Array[String] = []
	var core_hit_count := 0
	var defeated_count := 0
	var missed_pound_count := 0
	var boss_cues: Array[StringName] = []
	var impact_feedback_count := 0
	var last_shake_strength := 0.0
	var last_shake_seconds := 0.0
	var last_hitstop_seconds := 0.0
	var burst_count := 0

	func on_gear_guardian_state_changed(guardian, _state: int) -> void:
		state_changes.append(guardian.state_name())

	func on_gear_guardian_core_hit(_guardian, _hits: int, _limit: int) -> void:
		core_hit_count += 1

	func on_gear_guardian_defeated(_guardian) -> void:
		defeated_count += 1

	func on_gear_guardian_pound_missed(_guardian) -> void:
		missed_pound_count += 1

	func play_boss_cue(cue: StringName) -> void:
		boss_cues.append(cue)

	func boss_impact_feedback(shake_strength: float, shake_seconds: float, hitstop_seconds: float) -> void:
		impact_feedback_count += 1
		last_shake_strength = shake_strength
		last_shake_seconds = shake_seconds
		last_hitstop_seconds = hitstop_seconds

	func spawn_burst(_position: Vector2, _color: Color) -> void:
		burst_count += 1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := GuardianHarness.new()
	root.add_child(game)
	var guardian = GEAR_GUARDIAN_SCRIPT.new()
	game.add_child(guardian)
	guardian.setup(game, Vector2(4460.0, 566.0))

	guardian.activate()
	assert(guardian.activated)
	guardian.advance_phase(0.56)
	assert(guardian.state_name() == "TELEGRAPH_RIPPLE", "守衛應先預告齒輪波紋")
	guardian.advance_phase(0.90)
	assert(guardian.state_name() == "RIPPLE_ACTIVE", "波紋預告後應進入攻擊")
	guardian.advance_phase(1.82)
	assert(guardian.state_name() == "TELEGRAPH_PENDULUM", "地面波紋結束後應預告擺錘")
	guardian.advance_phase(0.90)
	assert(guardian.state_name() == "PENDULUM_ACTIVE", "擺錘預告後應進入慢速擺動")
	assert(guardian.pendulum_tip().distance_to(guardian.global_position) < 260.0)

	assert(not guardian.on_boomerang_hit(guardian.latch_position() + Vector2(130.0, 0.0)), "打偏卡榫不應觸發暈眩")
	assert(guardian.on_boomerang_hit(guardian.latch_position()), "命中黃銅卡榫應使守衛暈眩")
	assert(guardian.state_name() == "STUNNED")
	guardian.advance_phase(3.51)
	assert(guardian.state_name() == "TELEGRAPH_RIPPLE", "3.5 秒後守衛應復原並重啟攻擊節奏")

	assert(guardian.on_boomerang_hit(guardian.latch_position()))
	assert(guardian.on_ground_pound(guardian.exposed_core_position(), false), "非嘟嘟坐擊應被消耗但不造成核心傷害")
	assert(guardian.core_hits == 0)
	assert(guardian.on_ground_pound(guardian.exposed_core_position() + Vector2(0.0, 300.0), true))
	assert(guardian.core_hits == 0, "距離核心過遠不應計為命中")
	assert(guardian.on_ground_pound(guardian.exposed_core_position(), true))
	assert(guardian.core_hits == 1)
	assert(guardian.state_name() == "CORE_EXPOSED")
	guardian.advance_phase(0.73)
	assert(guardian.state_name() == "TELEGRAPH_PENDULUM", "第一次核心命中後應改變下一輪攻擊")
	guardian.advance_phase(0.90)
	assert(guardian.state_name() == "PENDULUM_ACTIVE")

	assert(guardian.on_boomerang_hit(guardian.latch_position()))
	assert(guardian.on_ground_pound(guardian.exposed_core_position(), true))
	assert(guardian.core_hits == 2)
	guardian.advance_phase(0.73)
	assert(guardian.state_name() == "TELEGRAPH_RIPPLE", "第二次核心命中後應再次交替攻擊")
	guardian.advance_phase(0.90)
	assert(guardian.state_name() == "RIPPLE_ACTIVE")

	assert(guardian.on_boomerang_hit(guardian.latch_position()))
	assert(guardian.on_ground_pound(guardian.exposed_core_position(), true))
	assert(guardian.is_defeated())
	assert(guardian.core_hits == 3)
	assert(game.core_hit_count == 2)
	assert(game.defeated_count == 1, "第三次有效坐擊應觸發解除閘門／鐘芯解鎖回呼")
	assert(guardian.finish_core_position().x > 4660.0, "解鎖鐘芯應位於守衛閘門後方")
	for cue in [&"boss_warning", &"boss_ripple", &"boss_pendulum", &"boss_latch", &"boss_core_hit", &"boss_defeat"]:
		assert(game.boss_cues.has(cue), "Boss 狀態應觸發對應音效：" + str(cue))
	assert(game.impact_feedback_count == 7, "卡榫、三次核心命中與擊敗應提供打擊回饋")
	assert(game.last_shake_strength >= 7.0, "擊敗一擊應使用最強相機震動")
	assert(game.last_shake_seconds >= 0.28 and game.last_hitstop_seconds >= 0.065, "擊敗一擊應有 280ms 震動與 65ms hit-stop")
	assert(guardian.hit_flash_time >= 0.24, "最後一擊應提供短暫高亮閃白")
	assert(game.burst_count == 7, "卡榫命中與核心命中應顯示爆光粒子")

	print("GEAR_GUARDIAN_MECHANICS_PASS")
	quit(0)
