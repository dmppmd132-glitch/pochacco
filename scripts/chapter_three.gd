extends Node2D
class_name ChapterThreeController

const STEAM_VENT_SCRIPT: Script = preload("res://scripts/steam_vent.gd")
const GEAR_GUARDIAN_SCRIPT: Script = preload("res://scripts/gear_guardian.gd")

var game
var gears: Array[GearPlatform] = []
var steam_vents: Array[Area2D] = []
var guardian
var bell_active := false
var core_unlocked := false
var core_restored := false
var brake_count := 0

class GearPlatform extends AnimatableBody2D:
	var size := Vector2(300.0, 30.0)
	var left_x := 0.0
	var right_x := 0.0
	var direction := 1.0
	var speed := 110.0
	var paused_time := 0.0
	var phase := 0.0
	var gear_id := ""
	var interaction_enabled := true

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
		phase += delta * direction
		if paused_time > 0.0:
			paused_time = maxf(0.0, paused_time - delta)
			queue_redraw()
			return
		var next_x := position.x + direction * speed * delta
		if next_x <= left_x or next_x >= right_x:
			next_x = clampf(next_x, left_x, right_x)
			direction *= -1.0
		position.x = next_x
		queue_redraw()

	func reverse_direction() -> void:
		direction *= -1.0
		queue_redraw()

	func brake_for(seconds: float) -> void:
		paused_time = maxf(paused_time, seconds)
		queue_redraw()

	func is_braked() -> bool:
		return paused_time > 0.0

	func _draw() -> void:
		var bounds := Rect2(-size * 0.5, size)
		var base := Color("#d99a58") if not is_braked() else Color("#efb45f")
		draw_rect(bounds, base, true)
		draw_rect(Rect2(bounds.position, Vector2(size.x, 9.0)), Color("#fff0c9"), true)
		draw_line(Vector2(bounds.position.x, 10.0), Vector2(bounds.end.x, 10.0), Color("#9c604b"), 3.0, true)
		for x in range(-int(size.x * 0.42), int(size.x * 0.43), 34):
			draw_circle(Vector2(x, -2), 4.0, Color("#ffe08a"))
		for x in [-size.x * 0.36, 0.0, size.x * 0.36]:
			draw_arc(Vector2(x, -size.y * 0.5 - 9.0), 12.0, 0.0, TAU, 12, Color("#a7654d"), 4.0, true)
		if is_braked():
			draw_line(Vector2(-18, -18), Vector2(18, -18), Color("#f6d46c"), 5.0, true)

func setup(controller_game) -> void:
	game = controller_game
	_build_gears()
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
	_add_gear("廣場齒輪", Vector2(690, 500), 520.0, 900.0, 118.0)
	_add_gear("工坊齒輪", Vector2(1900, 430), 1600.0, 2260.0, 132.0)
	_add_gear("鐘樓外環", Vector2(3230, 365), 2860.0, 3670.0, 148.0)

func _add_gear(id: String, at: Vector2, left_x: float, right_x: float, speed_value: float) -> void:
	var gear := GearPlatform.new()
	gear.name = id
	gear.gear_id = id
	gear.position = at
	gear.left_x = left_x
	gear.right_x = right_x
	gear.speed = speed_value
	add_child(gear)
	gears.append(gear)

func reverse_near(at_x: float) -> bool:
	var gear := _nearest_gear(at_x)
	if gear == null or absf(gear.position.x - at_x) > 260.0:
		return false
	gear.reverse_direction()
	bell_active = true
	game.show_toast("黃銅鈴響了！齒輪改變方向，觀察外圈箭頭找安全路線。")
	game._update_objective()
	return true

func brake_near(at_x: float) -> bool:
	var gear := _nearest_gear(at_x)
	if gear == null or absf(gear.position.x - at_x) > 220.0:
		return false
	gear.brake_for(5.0)
	brake_count += 1
	game.show_toast("煞車踏板卡住齒輪 5 秒！趁停靠記號對齊時跳上去。")
	game._update_objective()
	return true

func on_boomerang_hit(at_position: Vector2) -> bool:
	if is_instance_valid(guardian) and guardian.on_boomerang_hit(at_position):
		return true
	var at_x := at_position.x
	if at_x > 1030.0 and at_x < 1160.0:
		return reverse_near(1090.0)
	if at_x > 2580.0 and at_x < 2760.0:
		return reverse_near(2670.0)
	return false

func on_ground_pound(at_position: Vector2, is_dudu: bool) -> bool:
	if is_instance_valid(guardian) and absf(at_position.x - guardian.global_position.x) < 150.0:
		return guardian.on_ground_pound(at_position, is_dudu)
	if suppress_vent_near(at_position.x):
		return true
	if at_position.x > 980.0 and at_position.x < 1200.0:
		brake_near(1090.0)
		return true
	if at_position.x > 2500.0 and at_position.x < 2800.0:
		brake_near(2670.0)
		return true
	return false

func _nearest_gear(at_x: float) -> GearPlatform:
	var nearest: GearPlatform
	var distance := INF
	for gear in gears:
		var current_distance := absf(gear.position.x - at_x)
		if current_distance < distance:
			nearest = gear
			distance = current_distance
	return nearest

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
		var arrow_x := gear.position.x + (34.0 if gear.direction > 0.0 else -34.0)
		draw_line(Vector2(arrow_x, gear.position.y - 64), Vector2(arrow_x - 10.0 * gear.direction, gear.position.y - 52), Color("#fff6d2"), 5.0, true)
		draw_line(Vector2(arrow_x, gear.position.y - 64), Vector2(arrow_x + 10.0 * gear.direction, gear.position.y - 52), Color("#fff6d2"), 5.0, true)
	if game != null and game.GAME_FONT != null:
		var font: Font = game.GAME_FONT
		draw_string(font, Vector2(520, 558), "齒輪廣場｜看箭頭、聽黃銅鈴", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8e604f"))
		draw_string(font, Vector2(1660, 332), "發條工坊｜停靠記號", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8e604f"))
		draw_string(font, Vector2(2920, 265), "鐘樓外環｜安全窗口", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#8e604f"))
		draw_string(font, Vector2(2860, 602), "安全路線｜低平台・慢速齒輪・2 顆糖", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#527f70"))
		draw_string(font, Vector2(2860, 240), "高風險糖果路線｜高速齒輪・蒸汽噴口・多 3 顆糖", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#a35f4d"))
		if core_restored:
			draw_string(font, Vector2(4640, 500), "星星糖鐘芯已啟動", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#a66b42"))
