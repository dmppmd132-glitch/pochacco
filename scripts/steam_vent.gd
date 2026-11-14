extends Area2D
class_name SteamVent

signal phase_changed(phase: int)

enum Phase { PREHEAT, ERUPTING, COOLDOWN }

const PREHEAT_SECONDS := 0.8
const ERUPTION_SECONDS := 0.9
const CYCLE_SECONDS := 3.6
const COOLDOWN_SECONDS := CYCLE_SECONDS - PREHEAT_SECONDS - ERUPTION_SECONDS
const HIT_REPEAT_SECONDS := 1.2

var game: Node
var vent_id := ""
var cycle_offset := 0.0
var cycle_elapsed := 0.0
var phase: Phase = Phase.PREHEAT
var suppression_remaining := 0.0
var recovery_position := Vector2.ZERO
var _steam_shape: CollisionShape2D
var _hit_cooldowns: Dictionary = {}


func setup(game_ref: Node, id: String, at: Vector2, safe_return: Vector2, offset_seconds := 0.0) -> void:
	game = game_ref
	vent_id = id
	position = at
	recovery_position = safe_return
	cycle_offset = fposmod(offset_seconds, CYCLE_SECONDS)
	cycle_elapsed = cycle_offset
	phase = _phase_for_elapsed(cycle_elapsed)


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	_steam_shape = CollisionShape2D.new()
	_steam_shape.name = "SteamColumnShape"
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(76.0, 156.0)
	_steam_shape.shape = rectangle
	_steam_shape.position = Vector2(0.0, -78.0)
	add_child(_steam_shape)
	_update_collision()
	body_entered.connect(_on_body_entered)
	if phase == Phase.PREHEAT:
		_play_warning()
	queue_redraw()


func _process(delta: float) -> void:
	advance_phase(delta)
	for body_id in _hit_cooldowns.keys():
		var remaining := maxf(0.0, float(_hit_cooldowns[body_id]) - delta)
		if remaining <= 0.0:
			_hit_cooldowns.erase(body_id)
		else:
			_hit_cooldowns[body_id] = remaining
	if phase == Phase.ERUPTING and monitoring:
		for body in get_overlapping_bodies():
			_apply_to_body(body)
	queue_redraw()


func advance_phase(delta: float) -> void:
	if delta <= 0.0:
		return
	if suppression_remaining > 0.0:
		suppression_remaining -= delta
		if suppression_remaining > 0.0:
			_set_phase(Phase.COOLDOWN)
			return
		# Resume in the safe part of the cycle; never release a stomp directly into a plume.
		cycle_elapsed = PREHEAT_SECONDS + ERUPTION_SECONDS + maxf(0.0, -suppression_remaining)
		suppression_remaining = 0.0
	else:
		cycle_elapsed += delta
	cycle_elapsed = fposmod(cycle_elapsed, CYCLE_SECONDS)
	_set_phase(_phase_for_elapsed(cycle_elapsed))


func suppress_for(seconds: float) -> bool:
	if seconds <= 0.0:
		return false
	suppression_remaining = maxf(suppression_remaining, seconds)
	cycle_elapsed = PREHEAT_SECONDS + ERUPTION_SECONDS
	_set_phase(Phase.COOLDOWN)
	return true


func is_dangerous() -> bool:
	return phase == Phase.ERUPTING and suppression_remaining <= 0.0


func is_safe_window() -> bool:
	return phase == Phase.COOLDOWN or suppression_remaining > 0.0


func phase_name() -> String:
	match phase:
		Phase.PREHEAT:
			return "preheat"
		Phase.ERUPTING:
			return "erupting"
		_:
			return "cooldown"


func _phase_for_elapsed(value: float) -> Phase:
	if value < PREHEAT_SECONDS:
		return Phase.PREHEAT
	if value < PREHEAT_SECONDS + ERUPTION_SECONDS:
		return Phase.ERUPTING
	return Phase.COOLDOWN


func _set_phase(next_phase: Phase) -> void:
	if phase == next_phase:
		_update_collision()
		return
	phase = next_phase
	_update_collision()
	phase_changed.emit(phase)
	if phase == Phase.PREHEAT:
		_play_warning()


func _update_collision() -> void:
	if is_instance_valid(_steam_shape):
		_steam_shape.disabled = not is_dangerous()


func _play_warning() -> void:
	if is_instance_valid(game) and game.has_method("play_steam_warning"):
		game.play_steam_warning()


func _on_body_entered(body: Node2D) -> void:
	_apply_to_body(body)


func _apply_to_body(body: Node2D) -> void:
	if not is_dangerous() or not is_instance_valid(body) or not body.is_in_group("snackisle_buddy"):
		return
	var body_id := body.get_instance_id()
	if _hit_cooldowns.has(body_id):
		return
	_hit_cooldowns[body_id] = HIT_REPEAT_SECONDS
	if is_instance_valid(game) and game.has_method("handle_steam_vent_hit"):
		game.handle_steam_vent_hit(body, recovery_position, global_position.x)


func _draw() -> void:
	# A clear silhouette makes the safe window readable even without audio.
	if phase == Phase.PREHEAT:
		var blink := 0.72 + 0.28 * absf(sin(float(Time.get_ticks_msec()) * 0.012))
		draw_circle(Vector2(0.0, -8.0), 12.0, Color(1.0, 0.78, 0.22, blink))
		draw_arc(Vector2.ZERO, 20.0, PI, TAU, 16, Color("#b8874a"), 5.0, true)
	elif phase == Phase.ERUPTING:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-28.0, -3.0), Vector2(-21.0, -50.0), Vector2(-14.0, -82.0),
			Vector2(-23.0, -128.0), Vector2(0.0, -156.0), Vector2(22.0, -126.0),
			Vector2(14.0, -82.0), Vector2(26.0, -46.0), Vector2(29.0, -3.0),
		]), Color("#fffdf2", 0.88))
		draw_line(Vector2(-14.0, -18.0), Vector2(-7.0, -122.0), Color("#ffffff", 0.92), 4.0, true)
		draw_line(Vector2(13.0, -24.0), Vector2(8.0, -136.0), Color("#fff5db", 0.92), 4.0, true)
	else:
		draw_circle(Vector2(0.0, -8.0), 9.0, Color("#a9d9c1"))
		draw_arc(Vector2.ZERO, 20.0, PI, TAU, 16, Color("#b8874a"), 5.0, true)
	draw_rect(Rect2(-34.0, -5.0, 68.0, 13.0), Color("#9f6d50"), true)
	draw_rect(Rect2(-25.0, -13.0, 50.0, 9.0), Color("#e4bd77"), true)
