extends Node2D
class_name TidalJellyfishBoss

signal state_changed(state: int)
signal core_damaged(hit_count: int, hit_limit: int)
signal defeated

enum State {
	SLEEPING,
	TELEGRAPH_RIPPLE,
	RIPPLE_ACTIVE,
	TELEGRAPH_TIDE,
	TIDE_ACTIVE,
	ECHO_PLAYBACK,
	ECHO_RETRY,
	ECHO_INPUT,
	MIRROR_PUZZLE,
	CORE_EXPOSED,
	HIT_RECOVERY,
	DEFEATED,
}

const REQUIRED_CORE_HITS := 3
const TELEGRAPH_SECONDS := 1.0
const CORE_WINDOW_SECONDS := 4.0
const HIT_RECOVERY_SECONDS := 1.2
const ECHO_BEAT_SECONDS := 0.78
const ECHO_RETRY_SECONDS := 0.8
const ECHO_SEQUENCE := [0, 2]
const ECHO_TONES := [0, 2, 1]
const BOSS_X_MIN := 4220.0
const BOSS_X_MAX := 4900.0

var game: Node
var state: State = State.SLEEPING
var activated := false
var phase := 1
var core_hits := 0
var state_time := 0.0
var ripple_radius := 0.0
var tide_direction := -1.0
var echo_elapsed := 0.0
var echo_cursor := -1
var echo_input_index := 0
var echo_retry_remaining := 0.0
var mirror_orientations: Array[int] = [0, 0]
var mirror_lock_remaining := 0.0
var active_attack_id := 0
var attack_hit_ids: Dictionary = {}
var boomerang_hit_ids: Dictionary = {}
var hit_flash_time := 0.0
var _victory_emitted := false


func setup(controller_game: Node, spawn_position: Vector2) -> void:
	game = controller_game
	global_position = spawn_position
	queue_redraw()


func _process(delta: float) -> void:
	if not activated or state == State.DEFEATED or not is_instance_valid(game):
		return
	if game.get("run_over") or get_tree().paused:
		return
	if game.has_method("is_boss_hitstop_active") and game.is_boss_hitstop_active():
		return
	advance_phase(delta)


func advance_phase(delta: float) -> void:
	if delta <= 0.0 or state == State.DEFEATED:
		return
	state_time += delta
	hit_flash_time = maxf(0.0, hit_flash_time - delta)
	mirror_lock_remaining = maxf(0.0, mirror_lock_remaining - delta)
	match state:
		State.TELEGRAPH_RIPPLE:
			if state_time >= TELEGRAPH_SECONDS:
				ripple_radius = 42.0
				attack_hit_ids.clear()
				_set_state(State.RIPPLE_ACTIVE)
		State.RIPPLE_ACTIVE:
			var previous_radius := ripple_radius
			ripple_radius += 280.0 * delta
			if is_instance_valid(game) and game.has_method("tide_jelly_ripple_contact"):
				game.tide_jelly_ripple_contact(self, previous_radius, ripple_radius)
			if ripple_radius >= 500.0:
				_after_attack()
		State.TELEGRAPH_TIDE:
			if state_time >= TELEGRAPH_SECONDS:
				attack_hit_ids.clear()
				_set_state(State.TIDE_ACTIVE)
		State.TIDE_ACTIVE:
			if is_instance_valid(game) and game.has_method("tide_jelly_tide_contact"):
				game.tide_jelly_tide_contact(self)
			if state_time >= 2.0:
				_after_attack()
		State.ECHO_PLAYBACK:
			echo_elapsed += delta
			var next_cursor := mini(int(echo_elapsed / ECHO_BEAT_SECONDS), ECHO_SEQUENCE.size() - 1)
			if next_cursor != echo_cursor:
				echo_cursor = next_cursor
				_play_tone(ECHO_SEQUENCE[echo_cursor])
				queue_redraw()
			if echo_elapsed >= float(ECHO_SEQUENCE.size()) * ECHO_BEAT_SECONDS:
				echo_cursor = -1
				echo_input_index = 0
				_set_state(State.ECHO_INPUT)
		State.ECHO_RETRY:
			echo_retry_remaining = maxf(0.0, echo_retry_remaining - delta)
			if echo_retry_remaining <= 0.0:
				_begin_echo_playback()
		State.CORE_EXPOSED:
			if state_time >= CORE_WINDOW_SECONDS:
				if is_instance_valid(game) and game.has_method("show_toast"):
					game.show_toast("共鳴囊閉合了；水母王會重新預告一次，已取得的命中保留。")
				_begin_attack()
		State.HIT_RECOVERY:
			if state_time >= HIT_RECOVERY_SECONDS:
				_begin_attack()
	queue_redraw()


func activate() -> void:
	if activated or state == State.DEFEATED:
		return
	activated = true
	phase = 1
	boomerang_hit_ids.clear()
	_begin_attack()
	if is_instance_valid(game) and game.has_method("on_tidal_jellyfish_activated"):
		game.on_tidal_jellyfish_activated(self)


func _begin_attack() -> void:
	phase = clampi(core_hits + 1, 1, 3)
	active_attack_id += 1
	attack_hit_ids.clear()
	echo_cursor = -1
	echo_input_index = 0
	if phase == 2:
		tide_direction = -1.0 if active_attack_id % 2 == 1 else 1.0
		_set_state(State.TELEGRAPH_TIDE)
	else:
		_set_state(State.TELEGRAPH_RIPPLE)


func _after_attack() -> void:
	if phase == 3:
		_begin_echo_playback()
	else:
		_begin_mirror_puzzle()


func _begin_echo_playback() -> void:
	echo_elapsed = 0.0
	echo_cursor = -1
	echo_input_index = 0
	_set_state(State.ECHO_PLAYBACK)


func _begin_mirror_puzzle() -> void:
	mirror_orientations = [0, 0]
	mirror_lock_remaining = 0.0
	_set_state(State.MIRROR_PUZZLE)
	if is_instance_valid(game) and game.has_method("on_tidal_jellyfish_puzzle_started"):
		game.on_tidal_jellyfish_puzzle_started(self)


func _set_state(next_state: State) -> void:
	state = next_state
	state_time = 0.0
	state_changed.emit(state)
	if is_instance_valid(game) and game.has_method("on_tidal_jellyfish_state_changed"):
		game.on_tidal_jellyfish_state_changed(self, state)
	queue_redraw()


func on_boomerang_hit(world_position: Vector2, shot_id: int = -1) -> bool:
	if not activated or state == State.DEFEATED:
		return false
	if shot_id >= 0 and boomerang_hit_ids.has(shot_id):
		return false
	if state == State.ECHO_INPUT:
		for index in ECHO_TONES.size():
			if world_position.distance_to(echo_bell_position(index)) > 38.0:
				continue
			var tone: int = ECHO_TONES[index]
			if shot_id >= 0:
				boomerang_hit_ids[shot_id] = true
			_play_tone(tone)
			if tone != ECHO_SEQUENCE[echo_input_index]:
				echo_input_index = 0
				echo_retry_remaining = ECHO_RETRY_SECONDS
				_set_state(State.ECHO_RETRY)
				if is_instance_valid(game) and game.has_method("show_toast"):
					game.show_toast("音序不一樣，兩拍回音會重播；這不會扣命。")
				return true
			echo_input_index += 1
			if is_instance_valid(game) and game.has_method("show_toast"):
				game.show_toast("水母回音接上了 %d/2 拍。" % echo_input_index)
			if echo_input_index >= ECHO_SEQUENCE.size():
				_begin_mirror_puzzle()
			return true
	if state == State.MIRROR_PUZZLE:
		for index in _active_mirror_count():
			if world_position.distance_to(mirror_world_position(index)) > 50.0:
				continue
			if shot_id >= 0:
				boomerang_hit_ids[shot_id] = true
			mirror_orientations[index] = (mirror_orientations[index] + 1) % 4
			if _mirrors_aligned():
				_expose_core()
			queue_redraw()
			return true
	if state == State.MIRROR_PUZZLE and world_position.distance_to(weak_point_position()) <= 76.0:
		if is_instance_valid(game) and game.has_method("show_toast"):
			game.show_toast("迴旋鏢只能啟動共鳴機關；共鳴囊打開後要由嘟嘟空中坐擊。")
		return true
	return false


func cancel_echo_for_focus_loss() -> void:
	if state in [State.ECHO_PLAYBACK, State.ECHO_RETRY, State.ECHO_INPUT]:
		echo_retry_remaining = 0.3
		_set_state(State.ECHO_RETRY)


func interact_mirror_near(world_position: Vector2) -> bool:
	if state != State.MIRROR_PUZZLE:
		return false
	for index in _active_mirror_count():
		if world_position.distance_to(mirror_world_position(index)) > 180.0:
			continue
		if phase == 2 and index == 1 and mirror_orientations[0] != _target_orientation(0):
			if is_instance_valid(game) and game.has_method("show_toast"):
				game.show_toast("先把左側鏡面對準，再讓嘟嘟坐擊中央錨點固定 6 秒。")
			return false
		if phase == 2 and index == 1 and mirror_lock_remaining <= 0.0:
			if is_instance_valid(game) and game.has_method("show_toast"):
				game.show_toast("中央錨點尚未固定！切換嘟嘟，在錨點上空按 X／K 坐擊。")
			return false
		mirror_orientations[index] = (mirror_orientations[index] + 1) % 4
		if is_instance_valid(game) and game.has_method("show_toast"):
			game.show_toast("共鳴鏡旋轉 90 度；帕恰狗按嗅嗅可查看下一個方向。")
		if _mirrors_aligned():
			_expose_core()
		queue_redraw()
		return true
	return false


func on_ground_pound(world_position: Vector2, is_dudu: bool) -> bool:
	if not activated or state == State.DEFEATED:
		return false
	if state == State.MIRROR_PUZZLE and phase == 2 and is_dudu and world_position.distance_to(anchor_position()) <= 88.0:
		mirror_lock_remaining = 6.0
		if is_instance_valid(game) and game.has_method("show_toast"):
			game.show_toast("嘟嘟固定中央錨點 6 秒！趁窗口旋轉右側鏡面。")
		queue_redraw()
		return true
	if absf(world_position.x - global_position.x) > 132.0:
		return false
	if state != State.CORE_EXPOSED:
		if is_instance_valid(game) and game.has_method("show_toast"):
			game.show_toast("共鳴囊還沒打開！先躲過預告，再完成潮汐機關。")
		return true
	if not is_dudu:
		if is_instance_valid(game) and game.has_method("show_toast"):
			game.show_toast("切換嘟嘟，在共鳴囊露出時空中按 X／K 坐擊。")
		return true
	if world_position.distance_to(weak_point_position()) > 156.0:
		return true
	core_hits += 1
	hit_flash_time = 0.32
	core_damaged.emit(core_hits, REQUIRED_CORE_HITS)
	if is_instance_valid(game) and game.has_method("spawn_burst"):
		game.spawn_burst(weak_point_position(), Color("#fff1a6"))
	if core_hits >= REQUIRED_CORE_HITS:
		if _victory_emitted:
			return true
		_victory_emitted = true
		_set_state(State.DEFEATED)
		defeated.emit()
		if is_instance_valid(game) and game.has_method("on_tidal_jellyfish_defeated"):
			game.on_tidal_jellyfish_defeated(self)
	else:
		_set_state(State.HIT_RECOVERY)
		if is_instance_valid(game) and game.has_method("on_tidal_jellyfish_core_hit"):
			game.on_tidal_jellyfish_core_hit(self, core_hits, REQUIRED_CORE_HITS)
	queue_redraw()
	return true


func _mirrors_aligned() -> bool:
	for index in _active_mirror_count():
		if mirror_orientations[index] != _target_orientation(index):
			return false
	if phase == 2 and mirror_lock_remaining <= 0.0:
		return false
	return true


func _target_orientation(index: int) -> int:
	match phase:
		1: return 3 if index == 0 else 0
		2: return 2 if index == 0 else 1
		_: return 1 if index == 0 else 0


func _active_mirror_count() -> int:
	return 2 if phase == 2 else 1


func _play_tone(tone_index: int) -> void:
	if is_instance_valid(game) and game.has_method("play_chapter_four_tone"):
		game.play_chapter_four_tone(tone_index)


func mirror_world_position(index: int) -> Vector2:
	return global_position + Vector2(-155.0 if index == 0 else 155.0, -14.0)


func echo_bell_position(index: int) -> Vector2:
	return global_position + Vector2(-120.0 + 120.0 * float(index), -75.0)


func anchor_position() -> Vector2:
	return global_position + Vector2(0.0, 66.0)


func weak_point_position() -> Vector2:
	return global_position + Vector2(0.0, -66.0)


func _expose_core() -> void:
	_set_state(State.CORE_EXPOSED)
	if is_instance_valid(game) and game.has_method("on_tidal_jellyfish_core_exposed"):
		game.on_tidal_jellyfish_core_exposed(self, CORE_WINDOW_SECONDS)


func sniff_hint() -> String:
	if state in [State.TELEGRAPH_RIPPLE, State.TELEGRAPH_TIDE]:
		return "帕恰狗嗅到潮紋燈在蓄力；看地面雙環或大型箭頭，預告至少 1 秒後才會攻擊。"
	if state == State.TIDE_ACTIVE:
		return "水流正在向%s推；站進兩側凸起的安全凹槽，或逆流移動。" % ("右" if tide_direction > 0.0 else "左")
	if state == State.ECHO_INPUT:
		return "水母回音下一拍：第 %d 個發光珊瑚鐘。" % (ECHO_TONES.find(ECHO_SEQUENCE[echo_input_index]) + 1)
	if state == State.MIRROR_PUZZLE:
		if phase == 2:
			return "先對準左鏡，再由嘟嘟坐擊中央錨點固定 6 秒，最後轉右鏡。"
		return "帕恰狗嗅到月光方向：%s。靠近左側共鳴鏡按 F／Y 逐格旋轉。" % _orientation_hint(_target_orientation(0))
	if state == State.CORE_EXPOSED:
		return "共鳴囊已露出！換嘟嘟跳起，在 4 秒內空中按 X／K 坐擊。"
	return "潮汐水母王第 %d 階段：先看清預告，再輪流使用帕恰狗迴旋鏢與嘟嘟坐擊。" % phase


func _orientation_hint(orientation: int) -> String:
	match orientation:
		0: return "月光向上"
		1: return "月光向右"
		2: return "月光向下"
		_: return "月光向左"


func tide_force(world_position: Vector2) -> float:
	if state != State.TIDE_ACTIVE or world_position.y < 380.0 or world_position.x < BOSS_X_MIN or world_position.x > BOSS_X_MAX:
		return 0.0
	if absf(world_position.x - (global_position.x - 222.0)) < 50.0 or absf(world_position.x - (global_position.x + 222.0)) < 50.0:
		return 0.0
	return tide_direction * 320.0


func is_attack_active() -> bool:
	return state == State.RIPPLE_ACTIVE or state == State.TIDE_ACTIVE


func claim_attack_hit(buddy: Node) -> bool:
	if not is_instance_valid(buddy):
		return false
	var key := buddy.get_instance_id()
	if attack_hit_ids.has(key):
		return false
	attack_hit_ids[key] = true
	return true


func reset_after_full_death() -> void:
	core_hits = 0
	phase = 1
	activated = true
	_victory_emitted = false
	boomerang_hit_ids.clear()
	mirror_lock_remaining = 0.0
	_begin_attack()
	queue_redraw()


func state_name() -> String:
	match state:
		State.SLEEPING: return "SLEEPING"
		State.TELEGRAPH_RIPPLE: return "TELEGRAPH_RIPPLE"
		State.RIPPLE_ACTIVE: return "RIPPLE_ACTIVE"
		State.TELEGRAPH_TIDE: return "TELEGRAPH_TIDE"
		State.TIDE_ACTIVE: return "TIDE_ACTIVE"
		State.ECHO_PLAYBACK: return "ECHO_PLAYBACK"
		State.ECHO_RETRY: return "ECHO_RETRY"
		State.ECHO_INPUT: return "ECHO_INPUT"
		State.MIRROR_PUZZLE: return "MIRROR_PUZZLE"
		State.CORE_EXPOSED: return "CORE_EXPOSED"
		State.HIT_RECOVERY: return "HIT_RECOVERY"
		State.DEFEATED: return "DEFEATED"
	return "SLEEPING"


func _draw() -> void:
	var body_color := Color("#8bd7d0")
	if state in [State.TELEGRAPH_RIPPLE, State.TELEGRAPH_TIDE]:
		body_color = Color("#b3e8dc")
	elif state == State.CORE_EXPOSED:
		body_color = Color("#f2d886")
	elif state == State.DEFEATED:
		body_color = Color("#8eb6a8")
	if hit_flash_time > 0.0:
		body_color = Color("#fff9df")
	# Glass-jelly silhouette and soft bell-shaped mantle.
	draw_circle(Vector2(0.0, -18.0), 54.0, Color("#548c9e", 0.35))
	draw_circle(Vector2(0.0, -24.0), 46.0, body_color)
	draw_arc(Vector2(0.0, -24.0), 46.0, PI, TAU, 32, Color("#e0fff1"), 4.0, true)
	for index in 5:
		var x := -34.0 + float(index) * 17.0
		var sway := sin(float(index) * 1.4 + state_time * 2.5) * 8.0
		draw_line(Vector2(x, 12.0), Vector2(x + sway, 62.0), Color("#82c9c7"), 8.0, true)
		draw_circle(Vector2(x + sway, 62.0), 4.0, Color("#d8fff0"))
	draw_circle(Vector2(-13.0, -28.0), 4.0, Color("#425a6a"))
	draw_circle(Vector2(13.0, -28.0), 4.0, Color("#425a6a"))
	if state == State.CORE_EXPOSED or state == State.DEFEATED:
		draw_circle(weak_point_position(), 17.0, Color("#fff0a3"))
		draw_circle(weak_point_position(), 8.0, Color("#ffffff"))
	if state == State.TELEGRAPH_RIPPLE:
		for ring in 2:
			draw_arc(Vector2(0.0, 68.0), 65.0 + float(ring) * 34.0 + fmod(state_time * 26.0, 20.0), PI, TAU, 28, Color("#ffe5a0"), 5.0, true)
		draw_line(Vector2(-24.0, 88.0), Vector2(24.0, 88.0), Color("#fff4c2"), 4.0, true)
	elif state == State.RIPPLE_ACTIVE:
		draw_arc(Vector2(0.0, 68.0), ripple_radius, PI, TAU, 40, Color("#fff1b3"), 8.0, true)
	if state == State.TELEGRAPH_TIDE or state == State.TIDE_ACTIVE:
		var direction := tide_direction
		var arrow_color := Color("#ffe7a2") if state == State.TELEGRAPH_TIDE else Color("#f7c96f")
		var arrow_y := 90.0
		draw_line(Vector2(-68.0, arrow_y), Vector2(68.0, arrow_y), arrow_color, 7.0, true)
		var tip_x := 68.0 * direction
		draw_line(Vector2(tip_x, arrow_y), Vector2(tip_x - 16.0 * direction, arrow_y - 12.0), arrow_color, 6.0, true)
		draw_line(Vector2(tip_x, arrow_y), Vector2(tip_x - 16.0 * direction, arrow_y + 12.0), arrow_color, 6.0, true)
	if state == State.MIRROR_PUZZLE:
		for index in _active_mirror_count():
			var center := mirror_world_position(index) - global_position
			var angle := float(mirror_orientations[index]) * PI * 0.5
			var axis := Vector2(cos(angle), sin(angle))
			draw_circle(center, 19.0, Color("#28556a"))
			draw_line(center - axis * 15.0, center + axis * 15.0, Color("#e4fff2"), 6.0, true)
			if index == 0 and mirror_lock_remaining > 0.0:
				draw_arc(center, 28.0, 0.0, TAU, 24, Color("#ffeba3"), 3.0, true)
		if state in [State.ECHO_PLAYBACK, State.ECHO_INPUT, State.ECHO_RETRY]:
			for index in ECHO_TONES.size():
				var center := echo_bell_position(index) - global_position
				var active: bool = state == State.ECHO_PLAYBACK and echo_cursor >= 0 and echo_cursor < ECHO_SEQUENCE.size() and ECHO_TONES[index] == ECHO_SEQUENCE[echo_cursor]
				if state == State.ECHO_INPUT and echo_input_index > 0:
					active = ECHO_TONES[index] == ECHO_SEQUENCE[echo_input_index - 1]
				draw_circle(center, 15.0 if not active else 21.0, Color("#f4d889") if active else Color("#4d8493"))
				draw_circle(center, 7.0, Color("#fff8d8"))
		if game != null and game.get("GAME_FONT") != null:
			game.GAME_FONT # Keep the font resource rooted while the controller is active.
	# Three pearl pips remain readable even when the status is not in the HUD.
	for index in REQUIRED_CORE_HITS:
		var pip_color := Color("#ffe59b") if index < core_hits else Color("#5f8fa0")
		draw_circle(Vector2(-22.0 + float(index) * 22.0, -102.0), 7.0, pip_color)
