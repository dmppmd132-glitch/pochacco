extends SceneTree

const GAME_SCRIPT := preload("res://scripts/snackisle_game.gd")


func _initialize() -> void:
	set_meta("snackisle_chapter", 3)
	call_deferred("_run")


func _run() -> void:
	var game = GAME_SCRIPT.new()
	root.add_child(game)
	await process_frame

	assert(game.chapter_index == 3, "整合測試應載入糖霜齒輪城")
	assert(is_instance_valid(game.chapter_three.guardian), "第三章應建立發條糖果守衛")
	assert(is_instance_valid(game.boss_gate), "Boss 戰前應有鐘芯平台閘門")

	var guardian = game.chapter_three.guardian
	guardian.activate()
	for hit_index in 3:
		assert(guardian.on_boomerang_hit(guardian.latch_position()), "迴旋鏢應命中守衛卡榫")
		if hit_index == 0:
			game.dudu.controlled = true
			game.dudu.global_position = Vector2(guardian.global_position.x, game.GROUND_Y - 160.0)
			game.dudu.velocity = Vector2.ZERO
			await physics_frame
			await process_frame
			assert(not game.dudu.is_on_floor(), "嘟嘟應位於空中才能開始坐擊")
			game.dudu.start_ground_pound()
			assert(game.dudu.ground_pounding, "嘟嘟應進入坐擊落地狀態")
			for _frame in 60:
				await physics_frame
				if guardian.core_hits == 1:
					break
			assert(guardian.core_hits == 1, "嘟嘟實際坐擊落地應命中露出的核心")
		else:
			assert(guardian.on_ground_pound(guardian.exposed_core_position(), true), "嘟嘟應能坐擊露出的核心")
		if hit_index < 2:
			guardian.advance_phase(0.73)
		assert(guardian.core_hits == hit_index + 1)

	assert(game.chapter_three.core_unlocked, "守衛擊敗後應解鎖鐘芯")
	assert(game.boss_gate == null, "擊敗守衛後應解除鐘芯平台閘門")
	game.dudu.global_position = guardian.finish_core_position()
	game._process(0.016)
	assert(game.chapter_three.core_restored, "觸碰解鎖鐘芯後應記錄啟動")
	assert(game.run_over, "觸碰鐘芯後應完成章節並進入結算")
	assert(game.boss_shake_strength >= 7.0, "Boss 最後一擊應啟動最強 screen shake")
	assert(game.boss_hitstop_time > 0.0, "Boss 最後一擊應啟動短 hit-stop")

	print("GEAR_GUARDIAN_INTEGRATION_PASS")
	quit(0)
