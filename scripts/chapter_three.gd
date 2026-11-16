extends Node2D
class_name ChapterThreeController

const STEAM_VENT_SCRIPT: Script = preload("res://scripts/steam_vent.gd")
const GEAR_GUARDIAN_SCRIPT: Script = preload("res://scripts/gear_guardian.gd")
const TURN_WARNING_SECONDS := 0.5
const FIRST_BRAKE_TUTORIAL_SECONDS := 6.5
const STANDARD_BRAKE_SECONDS := 5.0

var game
var gears: Array[GearPlatform] = []
var steam_vents: Array[Area2D] = []
var guardian
var bell_active := false
var core_unlocked := false
var core_restored := false
var brake_count := 0
var brake_tutorial_used := false
var last_brake_duration := 0.0
var brake_was_active := false

const GEAR_SPECS := [
	{"id": "廣場齒輪", "position": Vector2(690.0, 500.0), "left_x": 520.0, "right_x": 900.0, "speed": 118.0, "linked_group_id": "square_route", "next_dock_marker": "廣場入口", "checkpoint_id": "ch3_square"},
	{"id": "工坊齒輪", "position": Vector2(1900.0, 430.0), "left_x": 1600.0, "right_x": 2260.0, "speed": 132.0, "initial_direction": 1.0, "linked_group_id": "workshop_pair", "next_dock_marker": "工坊低位停靠點", "checkpoint_id": "ch3_workshop_low"},
	{"id": "工坊高位齒輪", "position": Vector2(2220.0, 320.0), "left_x": 1960.0, "right_x": 2500.0, "speed": 132.0, "initial_direction": -1.0, "linked_group_id": "workshop_pair", "next_dock_marker": "工坊高位安全落點", "checkpoint_id": "ch3_workshop_high"},
	{"id": "鐘樓外環", "position": Vector2(3230.0, 365.0), "left_x": 2860.0, "right_x": 3670.0, "speed": 148.0, "linked_group_id": "tower_route", "next_dock_marker": "鐘樓外環安全窗", "checkpoint_id": "ch3_tower"},
]

const INTERACTION_SPECS := [
	{"id": "廣場黃銅鈴", "action": "reverse", "gear_id": "廣場齒輪", "x": 1090.0, "radius": 130.0},
	{"id": "工坊黃銅鈴", "action": "reverse", "gear_id": "工坊齒輪", "x": 1500.0, "radius": 150.0},
	{"id": "工坊煞車踏板", "action": "brake", "gear_id": "工坊齒輪", "x": 2670.0, "radius": 140.0},
	{"id": "工坊高位煞車踏板", "action": "brake", "gear_id": "工坊高位齒輪", "x": 2450.0, "radius": 140.0},
	{"id": "鐘樓黃銅鈴", "action": "reverse", "gear_id": "鐘樓外環", "x": 3920.0, "radius": 150.0},
]

var interaction_nodes: Array[Dictionary] = []


func _process(_delta: float) -> void:
	var brake_active := has_active_brake()
	if brake_active != brake_was_active:
		brake_was_active = brake_active
		if is_instance_valid(game):
			game._update_objective()


func has_active_brake() -> bool:
	for gear in gears:
		if is_instance_valid(gear) and gear.is_braked():
			return true
	return false


class GearPlatform extends AnimatableBody2D:
	var size := Vector2(300.0, 30.0)
	var left_x := 0.0
	var right_x := 0.0
	var direction := 1.0
	var speed := 110.0
	var paused_time := 0.0
	var brake_remaining := 0.0
	var phase := 0.0
	var gear_id := ""
	var linked_group_id := ""
	var brake_target := ""
	var next_dock_marker := ""
	var checkpoint_id := ""
	var gear_phase := 0.0
	var motion_delta := Vector2.ZERO
	var interaction_enabled := true
	var turn_warning_active := false
	var turn_warning_announced := false
	var warning_elapsed := 0.0

	func _ready() -> void:
		collision_layer = 1
		collision_mask = 0
		sync_to_physics = true
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = size
		shape.shape = rectangle
		add_child(shape)
		add_to_group("chapter_three_gear")
		queue_redraw()

	func _physics_process(delta: float) -> void:
		advance_motion(delta)

	func advance_motion(delta: float) -> void:
		motion_delta = Vector2.ZERO
		if delta <= 0.0:
			return
		phase += delta * direction
		if brake_remaining > 0.0:
			brake_remaining = maxf(0.0, brake_remaining - delta)
			paused_time = brake_remaining
			if brake_remaining <= 0.0:
				brake_target = ""
				gear_phase = _normalized_phase()
			queue_redraw()
			return
		var distance_to_turn := right_x - position.x if direction > 0.0 else position.x - left_x
		if distance_to_turn <= speed * TURN_WARNING_SECONDS and not turn_warning_announced:
			turn_warning_active = true
			turn_warning_announced = true
			warning_elapsed = 0.0
			var tree := Engine.get_main_loop() as SceneTree
			var audio := tree.root.get_node_or_null("GameAudio") if tree != null else null
			if audio != null and audio.has_method("play"):
				audio.play(&"gear_turn_warning")
		var previous_position := position
		var next_x := position.x + direction * speed * delta
		if next_x <= left_x or next_x >= right_x:
			next_x = clampf(next_x, left_x, right_x)
			direction *= -1.0
			turn_warning_active = false
			turn_warning_announced = false
		position.x = next_x
		motion_delta = position - previous_position
		gear_phase = _normalized_phase()
		if turn_warning_active:
			warning_elapsed += delta
		queue_redraw()

	func reverse_direction() -> void:
		direction *= -1.0
		turn_warning_active = false
		turn_warning_announced = false
		gear_phase = _normalized_phase()
		queue_redraw()

	func brake_for(seconds: float) -> void:
		brake_remaining = maxf(brake_remaining, seconds)
		paused_time = brake_remaining
		brake_target = gear_id
		queue_redraw()

	func is_braked() -> bool:
		return brake_remaining > 0.0

	func _normalized_phase() -> float:
		return inverse_lerp(left_x, right_x, position.x)

	func configure(spec: Dictionary) -> void:
		gear_id = String(spec.get("id", ""))
		position = spec.get("position", Vector2.ZERO)
		left_x = float(spec.get("left_x", position.x))
		right_x = float(spec.get("right_x", position.x))
		speed = float(spec.get("speed", speed))
		direction = float(spec.get("initial_direction", direction))
		linked_group_id = String(spec.get("linked_group_id", ""))
		next_dock_marker = String(spec.get("next_dock_marker", ""))
		checkpoint_id = String(spec.get("checkpoint_id", ""))
		gear_phase = _normalized_phase()

	func _draw() -> void:
		var bounds := Rect2(-size * 0.5, size)
		var base := Color("#d99a58") if not is_braked() else Color("#efb45f")
		draw_rect(bounds, base, true)
		draw_rect(Rect2(bounds.position, Vector2(size.x, 9.0)), Color("#fff0c9"), true)
		draw_line(Vector2(bounds.position.x, 10.0), Vector2(bounds.end.x, 10.0), Color("#9c604b"), 3.0, true)
		for x in range(-int(size.x * 0.42), int(size.x * 0.43), 34):
			draw_circle(Vector2(x, -2), 4.0, Color("#ffe08a"))
		var arrow_visible := not turn_warning_active or int(floor(warning_elapsed * 12.0)) % 2 == 0
		if arrow_visible:
			var arrow_color := Color("#8a493f") if not turn_warning_active else Color("#fff1a6")
			var arrow_origin := Vector2(0.0, -size.y * 0.5 - 17.0)
			var arrow_tip := arrow_origin + Vector2(direction * 24.0, 0.0)
			draw_line(arrow_origin, arrow_tip, arrow_color, 5.0, true)
			draw_line(arrow_tip, arrow_tip + Vector2(-direction * 9.0, -7.0), arrow_color, 4.0, true)
			draw_line(arrow_tip, arrow_tip + Vector2(-direction * 9.0, 7.0), arrow_color, 4.0, true)
		if turn_warning_active:
			draw_string(ThemeDB.fallback_font, Vector2(-34.0, -size.y * 0.5 - 27.0), "即將換向", HORIZONTAL_ALIGNMENT_CENTER, 68.0, 12, Color("#6f342e"))
		for x in [-size.x * 0.36, 0.0, size.x * 0.36]:
			draw_arc(Vector2(x, -size.y * 0.5 - 9.0), 12.0, 0.0, TAU, 12, Color("#a7654d"), 4.0, true)
		if is_braked():
			draw_line(Vector2(-18, -18), Vector2(18, -18), Color("#f6d46c"), 5.0, true)
func setup(controller_game) -> void:
	game = controller_game
	_build_gears()
	_build_interaction_nodes()
	_build_steam_vents()
	_build_guardian()
	queue_redraw()


func _build_steam_vents() -> void:
	# High-risk route only: the safe lower lane remains free of steam collision.
	var vent_specs := [
		["工坊蒸汽閥 A", Vector2(2970.0, 425.0), 0.0],
		["工坊蒸汽閥 B", Vector2(3260.0, 425.0), 1.2],
		["工坊蒸汽閥 C", Vector2(3540.0, 425.0), 2.4],
	]
	for spec in vent_specs:
		var vent: Area2D = STEAM_VENT_SCRIPT.new()
		vent.name = String(spec[0])
		vent.setup(game, String(spec[0]), spec[1], Vector2(2850.0, game.GROUND_Y - 27.0), float(spec[2]))
		add_child(vent)
		steam_vents.append(vent)


func _build_guardian() -> void:
	guardian = GEAR_GUARDIAN_SCRIPT.new()
	guardian.name = "GearCandyGuardian"
	add_child(guardian)
	guardian.setup(game, Vector2(4460.0, game.GROUND_Y - 54.0))

func activate_guardian() -> void:
	if is_instance_valid(guardian):
		guardian.activate()

func steam_hint(at_x: float) -> String:
	var nearest: Area2D
	var nearest_distance := INF
	for vent in steam_vents:
		if not is_instance_valid(vent):
			continue
		var distance := absf(vent.global_position.x - at_x)
		if distance < nearest_distance:
			nearest = vent
			nearest_distance = distance
	if nearest == null or nearest_distance > 520.0:
		return ""
	var state: String = nearest.call("phase_name")
	match state:
		"preheat": return "帕恰狗嗅到蒸汽閥正在預熱！黃燈閃爍時先停下，噴發後再走。"
		"erupting": return "帕恰狗嗅到蒸汽正在噴發！等白色蒸汽散去，或讓嘟嘟坐擊壓住附近閥門。"
		_: return "帕恰狗嗅到蒸汽閥已冷卻；現在是安全通過窗口。"


func suppress_vent_near(at_x: float) -> bool:
	var nearest: Area2D
	var nearest_distance := INF
	for vent in steam_vents:
		if not is_instance_valid(vent):
			continue
		var distance := absf(vent.global_position.x - at_x)
		if distance < nearest_distance:
			nearest = vent
			nearest_distance = distance
	if nearest == null or nearest_distance > 145.0:
		return false
	var suppressed: bool = nearest.call("suppress_for", 2.4)
	if suppressed:
		game.show_toast("蒸汽閥被嘟嘟壓住 2.4 秒！趁安全窗口通過。")
	return suppressed
func _build_gears() -> void:
	gears.clear()
	for spec in GEAR_SPECS:
		_add_gear(spec)

func _build_interaction_nodes() -> void:
	interaction_nodes.clear()
	for spec in INTERACTION_SPECS:
		interaction_nodes.append(spec.duplicate(true))

func _add_gear(spec: Dictionary) -> void:
	var gear := GearPlatform.new()
	gear.name = String(spec["id"])
	gear.configure(spec)
	add_child(gear)
	gears.append(gear)

func reverse_near(at_x: float) -> bool:
	var node := _nearest_interaction(at_x, "reverse")
	if node.is_empty():
		return false
	var gear := _gear_by_id(String(node["gear_id"]))
	if gear == null:
		return false
	_reverse_linked_group(gear.linked_group_id)
	bell_active = true
	game.show_toast("黃銅鈴響了！%s 群組改變方向，下一個停靠點：%s。" % [gear.linked_group_id, gear.next_dock_marker])
	game._update_objective()
	return true

func brake_near(at_x: float) -> bool:
	var node := _nearest_interaction(at_x, "brake")
	if node.is_empty():
		return false
	var gear := _gear_by_id(String(node["gear_id"]))
	if gear == null:
		return false
	var brake_duration := FIRST_BRAKE_TUTORIAL_SECONDS if not brake_tutorial_used else STANDARD_BRAKE_SECONDS
	brake_tutorial_used = true
	last_brake_duration = brake_duration
	gear.brake_for(brake_duration)
	brake_count += 1
	if is_equal_approx(brake_duration, FIRST_BRAKE_TUTORIAL_SECONDS):
		game.show_toast("第一次煞車教學：%s 停靠 6.5 秒，留意對齊記號再跳躍！" % gear.gear_id)
	else:
		game.show_toast("煞車踏板卡住 %s 5 秒！趁停靠記號對齊時跳上去。" % gear.gear_id)
	game._update_objective()
	return true

func on_boomerang_hit(at_position: Vector2) -> bool:
	if is_instance_valid(guardian) and guardian.on_boomerang_hit(at_position):
		return true
	return reverse_near(at_position.x)

func on_ground_pound(at_position: Vector2, is_dudu: bool) -> bool:
	if is_instance_valid(guardian) and absf(at_position.x - guardian.global_position.x) < 150.0:
		return guardian.on_ground_pound(at_position, is_dudu)
	if suppress_vent_near(at_position.x):
		return true
	return brake_near(at_position.x)

func _nearest_interaction(at_x: float, action: String) -> Dictionary:
	var nearest := {}
	var distance := INF
	for node in interaction_nodes:
		if String(node.get("action", "")) != action:
			continue
		var node_distance := absf(float(node.get("x", 0.0)) - at_x)
		if node_distance <= float(node.get("radius", 0.0)) and node_distance < distance:
			nearest = node
			distance = node_distance
	return nearest

func _gear_by_id(gear_id: String) -> GearPlatform:
	for gear in gears:
		if gear.gear_id == gear_id:
			return gear
	return null

func _reverse_linked_group(group_id: String) -> void:
	for gear in gears:
		if gear.linked_group_id == group_id:
			gear.reverse_direction()

func mark_core_restored() -> void:
	if not core_unlocked or core_restored:
		return
	core_restored = true
	game.show_toast("觸碰星星糖鐘芯！糖霜齒輪城恢復了節拍。")
	game._update_objective()
	queue_redraw()

func _draw() -> void:
	for gear in gears:
		var tint := Color("#f6d26e") if gear.is_braked() else Color("#c98b51")
		draw_circle(gear.position + Vector2(0, -30), 28.0, tint)
		draw_circle(gear.position + Vector2(0, -30), 12.0, Color("#fff0bf"))
	if game != null and game.GAME_FONT != null:
		var font: Font = game.GAME_FONT
		draw_string(font, Vector2(520, 558), "齒輪廣場｜看箭頭、聽黃銅鈴", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8e604f"))
		draw_string(font, Vector2(1660, 332), "發條工坊｜停靠記號", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8e604f"))
		draw_string(font, Vector2(2920, 265), "鐘樓外環｜安全窗口", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8e604f"))
		draw_string(font, Vector2(2860, 602), "安全路線｜低平台・慢速齒輪・2 顆糖", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#527f70"))
		draw_string(font, Vector2(2860, 240), "高風險糖果路線｜高速齒輪・蒸汽噴口・多 3 顆糖", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a35f4d"))
		if core_restored:
			draw_string(font, Vector2(4640, 500), "星星糖鐘芯已啟動", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#a66b42"))
