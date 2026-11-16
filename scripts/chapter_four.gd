extends Node2D
class_name ChapterFourController

signal echo_state_changed(state: int)
signal echo_solved
signal prism_state_changed(is_lit: bool)
signal prism_solved

const ECHO_SEQUENCE := [0, 2, 1]
const ECHO_BELL_POSITIONS := [Vector2(890.0, 520.0), Vector2(1000.0, 520.0), Vector2(1110.0, 520.0)]
const ECHO_BEAT_SECONDS := 0.78
const ECHO_RETRY_SECONDS := 0.8
const ECHO_INPUT_SECONDS := 8.0
const PRISM_ORIGIN := Vector2(2210.0, 358.0)
const PRISM_CELL_SIZE := Vector2(88.0, 82.0)
const PRISM_GRID_SIZE := Vector2i(5, 3)
const PRISM_SOURCE := Vector2i(0, 2)
const PRISM_RECEIVER := Vector2i(4, 0)
const PRISM_MIRROR_CELLS: Array[Vector2i] = [Vector2i(2, 2), Vector2i(2, 0)]
const PRISM_MAX_STEPS := 24

const DIRS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]
const SLASH_REFLECTION := [1, 0, 3, 2]
const BACKSLASH_REFLECTION := [3, 2, 1, 0]

enum EchoState { IDLE, LISTENING, INPUT, SUCCESS, RETRY }

var game
var echo_gate
var mirror_gate
var echo_state := EchoState.IDLE
var echo_solved_flag := false
var echo_elapsed := 0.0
var echo_retry_remaining := 0.0
var echo_input_remaining := 0.0
var echo_input_index := 0
var echo_listen_cursor := -1
var echo_started := false
var prism_orientations: Array[int] = [1, 1]
var prism_lit := false
var prism_path: Array[Vector2i] = []
var prism_stopped_by_loop := false


func setup(controller_game) -> void:
	game = controller_game
	_update_prism_path()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	match echo_state:
		EchoState.LISTENING:
			echo_elapsed += delta
			var next_cursor := mini(int(echo_elapsed / ECHO_BEAT_SECONDS), ECHO_SEQUENCE.size() - 1)
			if next_cursor != echo_listen_cursor:
				echo_listen_cursor = next_cursor
				_play_echo_tone(ECHO_SEQUENCE[echo_listen_cursor])
				queue_redraw()
			if echo_elapsed >= ECHO_SEQUENCE.size() * ECHO_BEAT_SECONDS:
				echo_state = EchoState.INPUT
				echo_input_remaining = ECHO_INPUT_SECONDS
				echo_listen_cursor = -1
				echo_state_changed.emit(echo_state)
				queue_redraw()
		EchoState.RETRY:
			echo_retry_remaining = maxf(0.0, echo_retry_remaining - delta)
			if echo_retry_remaining <= 0.0:
				_begin_echo_playback()
		EchoState.INPUT:
			echo_input_remaining = maxf(0.0, echo_input_remaining - delta)
			if echo_input_remaining <= 0.0:
				_cancel_echo_attempt("回音散開了，再靠近珊瑚鐘重新聽一次。")


func begin_echo() -> bool:
	if echo_solved_flag or echo_started:
		return false
	echo_started = true
	_begin_echo_playback()
	return true


func _begin_echo_playback() -> void:
	echo_elapsed = 0.0
	echo_input_index = 0
	echo_input_remaining = ECHO_INPUT_SECONDS
	echo_listen_cursor = -1
	echo_state = EchoState.LISTENING
	echo_state_changed.emit(echo_state)
	queue_redraw()


func is_accepting_echo_input() -> bool:
	return echo_state == EchoState.INPUT


func _play_echo_tone(tone_index: int) -> void:
	if game != null and game.has_method("play_chapter_four_tone"):
		game.play_chapter_four_tone(tone_index)


func input_tone(tone_index: int) -> bool:
	if echo_state != EchoState.INPUT or echo_solved_flag:
		return false
	if tone_index >= 0 and tone_index < ECHO_BELL_POSITIONS.size():
		_play_echo_tone(tone_index)
	if tone_index != ECHO_SEQUENCE[echo_input_index]:
		echo_state = EchoState.RETRY
		echo_retry_remaining = ECHO_RETRY_SECONDS
		echo_input_index = 0
		echo_state_changed.emit(echo_state)
		queue_redraw()
		return false
	echo_input_index += 1
	echo_input_remaining = ECHO_INPUT_SECONDS
	if echo_input_index >= ECHO_SEQUENCE.size():
		echo_solved_flag = true
		echo_state = EchoState.SUCCESS
		echo_state_changed.emit(echo_state)
		echo_solved.emit()
		if game != null and game.has_method("on_chapter_four_echo_solved"):
			game.on_chapter_four_echo_solved()
		queue_redraw()
		return true
	queue_redraw()
	return true


func cancel_echo_for_focus_loss() -> void:
	if echo_solved_flag:
		return
	echo_started = false
	echo_elapsed = 0.0
	echo_retry_remaining = 0.0
	echo_input_remaining = 0.0
	echo_input_index = 0
	echo_listen_cursor = -1
	echo_state = EchoState.IDLE
	echo_state_changed.emit(echo_state)
	queue_redraw()


func echo_hint() -> String:
	if echo_solved_flag:
		return "回音珊瑚廊已共鳴，前方玻璃礁的兩面鏡子還沒對準。"
	if echo_state == EchoState.INPUT and echo_input_index < ECHO_SEQUENCE.size():
		return "帕恰狗嗅到下一個回音方向：第 %d 個珊瑚鐘。" % (ECHO_SEQUENCE[echo_input_index] + 1)
	return "帕恰狗嗅到月潮回音：先聽完整音序，再依序敲亮的珊瑚鐘。"


func _cancel_echo_attempt(message: String) -> void:
	echo_started = false
	echo_state = EchoState.IDLE
	echo_input_index = 0
	echo_input_remaining = 0.0
	echo_listen_cursor = -1
	echo_state_changed.emit(echo_state)
	if game != null and game.has_method("show_toast"):
		game.show_toast(message)
	queue_redraw()


func hit_bell(tone_index: int) -> bool:
	if tone_index < 0 or tone_index >= ECHO_BELL_POSITIONS.size():
		return false
	if echo_state == EchoState.IDLE and not echo_started:
		begin_echo()
		return false
	return input_tone(tone_index)


func rotate_mirror(index: int) -> bool:
	if not echo_solved_flag or index < 0 or index >= prism_orientations.size() or prism_lit:
		return false
	prism_orientations[index] = (prism_orientations[index] + 1) % 4
	_update_prism_path()
	prism_state_changed.emit(prism_lit)
	if prism_lit and game != null and game.has_method("on_chapter_four_prism_solved"):
		game.on_chapter_four_prism_solved()
	queue_redraw()
	return true


func rotate_mirror_near(world_position: Vector2) -> bool:
	if not echo_solved_flag or prism_lit:
		return false
	for index in PRISM_MIRROR_CELLS.size():
		var delta := world_position - _cell_world_position(PRISM_MIRROR_CELLS[index])
		if absf(delta.x) <= 112.0 and absf(delta.y) <= 118.0:
			return rotate_mirror(index)
	return false


func mirror_world_position(index: int) -> Vector2:
	if index < 0 or index >= PRISM_MIRROR_CELLS.size():
		return Vector2.INF
	return _cell_world_position(PRISM_MIRROR_CELLS[index])


func trace_prism(mirror_cells: Array[Vector2i], orientations: Array[int], max_steps: int = PRISM_MAX_STEPS) -> Dictionary:
	var position := PRISM_SOURCE
	var direction_index := 0
	var path: Array[Vector2i] = [position]
	var visited: Dictionary = {}
	var mirror_index_by_cell: Dictionary = {}
	for index in mini(mirror_cells.size(), orientations.size()):
		mirror_index_by_cell[mirror_cells[index]] = index
	for _step in max_steps:
		position += DIRS[direction_index]
		if position.x < 0 or position.y < 0 or position.x >= PRISM_GRID_SIZE.x or position.y >= PRISM_GRID_SIZE.y:
			return {"lit": false, "path": path, "loop": false, "reason": "邊界"}
		path.append(position)
		if position == PRISM_RECEIVER:
			return {"lit": true, "path": path, "loop": false, "reason": "接收器"}
		var state_key := "%d,%d,%d" % [position.x, position.y, direction_index]
		if visited.has(state_key):
			return {"lit": false, "path": path, "loop": true, "reason": "循環"}
		visited[state_key] = true
		if mirror_index_by_cell.has(position):
			var mirror_index: int = mirror_index_by_cell[position]
			var orientation: int = posmod(orientations[mirror_index], 4)
			direction_index = (SLASH_REFLECTION if orientation % 2 == 0 else BACKSLASH_REFLECTION)[direction_index]
	return {"lit": false, "path": path, "loop": false, "reason": "超出步數"}


func _update_prism_path() -> void:
	var result := trace_prism(PRISM_MIRROR_CELLS, prism_orientations)
	prism_lit = bool(result["lit"])
	prism_path = result["path"]
	prism_stopped_by_loop = bool(result["loop"])


func _cell_world_position(cell: Vector2i) -> Vector2:
	return PRISM_ORIGIN + Vector2((float(cell.x) + 0.5) * PRISM_CELL_SIZE.x, (float(cell.y) + 0.5) * PRISM_CELL_SIZE.y)


func _draw() -> void:
	for index in ECHO_BELL_POSITIONS.size():
		var center: Vector2 = ECHO_BELL_POSITIONS[index]
		var lit: bool = (echo_state == EchoState.LISTENING and echo_listen_cursor >= 0 and ECHO_SEQUENCE[echo_listen_cursor] == index) or (echo_state == EchoState.INPUT and echo_input_index > 0 and ECHO_SEQUENCE[echo_input_index - 1] == index)
		draw_circle(center, 30.0, Color("#83e3df") if lit else Color("#478d99"))
		draw_circle(center, 23.0, Color("#d7fffa") if lit else Color("#93c8c8"))
		draw_circle(center + Vector2(-7.0, -7.0), 5.0, Color("#fff9db"))
		if game != null and game.GAME_FONT != null:
			draw_string(game.GAME_FONT, center + Vector2(-6.0, 7.0), str(index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#315f6c"))
	if game != null and game.GAME_FONT != null:
		var instruction := "帕恰狗：先聽回音，再用迴旋鏢敲亮的珊瑚鐘" if not echo_solved_flag else ("已共鳴｜靠近鏡面按 F／Y 旋轉，讓月光照亮接收器" if not prism_lit else "月光接通了！安全通道已開啟")
		draw_string(game.GAME_FONT, Vector2(680.0, 458.0), instruction, HORIZONTAL_ALIGNMENT_LEFT, 760.0, 17, Color("#d9fff6"))
	var source := _cell_world_position(PRISM_SOURCE)
	var receiver := _cell_world_position(PRISM_RECEIVER)
	for y in range(PRISM_GRID_SIZE.y):
		for x in range(PRISM_GRID_SIZE.x):
			var rect := Rect2(PRISM_ORIGIN + Vector2(x * PRISM_CELL_SIZE.x, y * PRISM_CELL_SIZE.y), PRISM_CELL_SIZE)
			draw_rect(rect, Color("#173d56", 0.28), false, 2.0)
	draw_circle(source, 16.0, Color("#ffe797"))
	draw_circle(receiver, 18.0, Color("#a4ffe1") if prism_lit else Color("#628c9b"))
	for index in PRISM_MIRROR_CELLS.size():
		var mirror_center := _cell_world_position(PRISM_MIRROR_CELLS[index])
		var color := Color("#efffff") if prism_orientations[index] % 2 == 0 else Color("#9de7ee")
		var mirror_end := mirror_center + Vector2(19.0, -19.0) if prism_orientations[index] % 2 == 0 else mirror_center + Vector2(19.0, 19.0)
		draw_line(mirror_center + Vector2(-19.0, 19.0), mirror_end, color, 7.0, true)
	for index in range(1, prism_path.size()):
		var from := _cell_world_position(prism_path[index - 1])
		var to := _cell_world_position(prism_path[index])
		draw_line(from, to, Color("#fff1a8", 0.92) if prism_lit else Color("#83cfdd", 0.78), 5.0, true)
	if prism_lit:
		draw_circle(receiver, 29.0, Color("#bdfff1", 0.22), false, 4.0, true)
