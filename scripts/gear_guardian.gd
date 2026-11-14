extends Node2D
class_name GearGuardian

signal phase_changed(phase: int)
signal core_damaged(hit_count: int, hit_limit: int)
signal defeated

enum State {
	IDLE,
	TELEGRAPH_RIPPLE,
	RIPPLE_ACTIVE,
	TELEGRAPH_PENDULUM,
	PENDULUM_ACTIVE,
	STUNNED,
	CORE_EXPOSED,
	DEFEATED,
}

const REQUIRED_CORE_HITS := 3
const STUN_DURATION := 3.5
const LATCH_HIT_RADIUS := 54.0
const CORE_HIT_RADIUS_X := 92.0
const CORE_HIT_RADIUS_Y := 142.0

var game: Node
var state: State = State.IDLE
var activated := false
var state_time := 0.0
var core_hits := 0
var ripple_radius := 0.0
var pendulum_phase := 0.0
var _attack_hit_ids: Dictionary = {}
var hit_flash_time := 0.0
var _impact_tween: Tween


func setup(controller_game: Node, spawn_position: Vector2) -> void:
	game = controller_game
	global_position = spawn_position
	queue_redraw()


func activate() -> void:
	if activated or state == State.DEFEATED:
		return
	activated = true
	state = State.IDLE
	state_time = 0.0
	phase_changed.emit(state)
	if is_instance_valid(game) and game.has_method("on_gear_guardian_state_changed"):
		game.on_gear_guardian_state_changed(self, state)
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
	match state:
		State.IDLE:
			if state_time >= 0.55:
				_set_state(State.TELEGRAPH_RIPPLE)
		State.TELEGRAPH_RIPPLE:
			if state_time >= _telegraph_duration():
				ripple_radius = 0.0
				_attack_hit_ids.clear()
				_set_state(State.RIPPLE_ACTIVE)
		State.RIPPLE_ACTIVE:
			var previous_radius := ripple_radius
			ripple_radius += 176.0 * _rhythm_scale() * delta
			if is_instance_valid(game) and game.has_method("guardian_ripple_contact"):
				game.guardian_ripple_contact(self, previous_radius, ripple_radius)
			if ripple_radius >= 300.0:
				_set_state(State.TELEGRAPH_PENDULUM)
		State.TELEGRAPH_PENDULUM:
			if state_time >= _telegraph_duration():
				pendulum_phase = 0.0
				_attack_hit_ids.clear()
				_set_state(State.PENDULUM_ACTIVE)
		State.PENDULUM_ACTIVE:
			pendulum_phase = state_time * (1.0 + 0.14 * float(core_hits))
			if is_instance_valid(game) and game.has_method("guardian_pendulum_contact"):
				game.guardian_pendulum_contact(self, pendulum_tip())
			if state_time >= 3.1:
				_set_state(State.TELEGRAPH_RIPPLE)
		State.STUNNED:
			if state_time >= STUN_DURATION:
				_enter_next_attack()
		State.CORE_EXPOSED:
			if state_time >= 0.72:
				_enter_next_attack()
	queue_redraw()


func _telegraph_duration() -> float:
	return maxf(0.48, 0.88 - 0.1 * float(core_hits))


func _rhythm_scale() -> float:
	return 1.0 + 0.16 * float(core_hits)


func _enter_next_attack() -> void:
	# Each successful core hit alternates the next attack and tightens its rhythm.
	if core_hits % 2 == 1:
		_set_state(State.TELEGRAPH_PENDULUM)
	else:
		_set_state(State.TELEGRAPH_RIPPLE)


func _set_state(next_state: State) -> void:
	state = next_state
	state_time = 0.0
	phase_changed.emit(state)
	if is_instance_valid(game) and game.has_method("on_gear_guardian_state_changed"):
		game.on_gear_guardian_state_changed(self, state)
	match state:
		State.TELEGRAPH_RIPPLE, State.TELEGRAPH_PENDULUM: _play_boss_cue(&"boss_warning")
		State.RIPPLE_ACTIVE: _play_boss_cue(&"boss_ripple")
		State.PENDULUM_ACTIVE: _play_boss_cue(&"boss_pendulum")
		State.STUNNED: _play_boss_cue(&"boss_latch")
		State.DEFEATED: _play_boss_cue(&"boss_defeat")
	queue_redraw()

func _play_boss_cue(cue: StringName) -> void:
	if is_instance_valid(game) and game.has_method("play_boss_cue"):
		game.play_boss_cue(cue)
		return
	var audio := get_node_or_null("/root/GameAudio")
	if is_instance_valid(audio) and audio.has_method("play"):
		audio.call("play", cue)
func _impact(scale_multiplier: float, flash_seconds: float, shake_strength: float, shake_seconds: float, hitstop_seconds: float) -> void:
	hit_flash_time = maxf(hit_flash_time, flash_seconds)
	if is_instance_valid(_impact_tween) and _impact_tween.is_running():
		_impact_tween.kill()
	_impact_tween = create_tween()
	_impact_tween.tween_property(self, "scale", Vector2.ONE * scale_multiplier, 0.055)
	_impact_tween.tween_property(self, "scale", Vector2.ONE, 0.17)
	if is_instance_valid(game) and game.has_method("boss_impact_feedback"):
		game.boss_impact_feedback(shake_strength, shake_seconds, hitstop_seconds)

func on_boomerang_hit(world_position: Vector2) -> bool:
	if not activated or state in [State.STUNNED, State.CORE_EXPOSED, State.DEFEATED]:
		return false
	if world_position.distance_to(latch_position()) > LATCH_HIT_RADIUS:
		return false
	_set_state(State.STUNNED)
	if is_instance_valid(game) and game.has_method("spawn_burst"):
		game.spawn_burst(latch_position(), Color("#ffe58c"))
	_impact(1.12, 0.15, 2.2, 0.13, 0.025)
	return true


func on_ground_pound(world_position: Vector2, is_dudu: bool) -> bool:
	if absf(world_position.x - global_position.x) > CORE_HIT_RADIUS_X + 24.0:
		return false
	if not is_dudu:
		return true
	if state != State.STUNNED:
		if is_instance_valid(game) and game.has_method("on_gear_guardian_pound_missed"):
			game.on_gear_guardian_pound_missed(self)
		return true
	if absf(world_position.y - exposed_core_position().y) > CORE_HIT_RADIUS_Y:
		return true
	core_hits += 1
	core_damaged.emit(core_hits, REQUIRED_CORE_HITS)
	_play_boss_cue(&"boss_core_hit")
	if is_instance_valid(game) and game.has_method("spawn_burst"):
		game.spawn_burst(exposed_core_position(), Color("#fff0a1"))
	if core_hits >= REQUIRED_CORE_HITS:
		_impact(1.30, 0.24, 7.0, 0.28, 0.065)
		_set_state(State.DEFEATED)
		defeated.emit()
		if is_instance_valid(game) and game.has_method("on_gear_guardian_defeated"):
			game.on_gear_guardian_defeated(self)
	else:
		_impact(1.20, 0.18, 4.2, 0.19, 0.045)
		_set_state(State.CORE_EXPOSED)
		if is_instance_valid(game) and game.has_method("on_gear_guardian_core_hit"):
			game.on_gear_guardian_core_hit(self, core_hits, REQUIRED_CORE_HITS)
	return true


func latch_position() -> Vector2:
	return global_position + Vector2(-43.0, -20.0)


func exposed_core_position() -> Vector2:
	return global_position + Vector2(0.0, -35.0)


func finish_core_position() -> Vector2:
	return global_position + Vector2(300.0, -14.0)


func is_core_open() -> bool:
	return state == State.STUNNED or state == State.CORE_EXPOSED or state == State.DEFEATED


func is_defeated() -> bool:
	return state == State.DEFEATED


func claim_attack_hit(buddy: Node) -> bool:
	if not is_instance_valid(buddy):
		return false
	var instance_id := buddy.get_instance_id()
	if _attack_hit_ids.has(instance_id):
		return false
	_attack_hit_ids[instance_id] = true
	return true


func pendulum_tip() -> Vector2:
	var angle := sin(pendulum_phase) * 0.72
	return global_position + Vector2(sin(angle) * 260.0, -250.0 + cos(angle) * 260.0)


func state_name() -> String:
	match state:
		State.IDLE: return "IDLE"
		State.TELEGRAPH_RIPPLE: return "TELEGRAPH_RIPPLE"
		State.RIPPLE_ACTIVE: return "RIPPLE_ACTIVE"
		State.TELEGRAPH_PENDULUM: return "TELEGRAPH_PENDULUM"
		State.PENDULUM_ACTIVE: return "PENDULUM_ACTIVE"
		State.STUNNED: return "STUNNED"
		State.CORE_EXPOSED: return "CORE_EXPOSED"
		State.DEFEATED: return "DEFEATED"
	return "IDLE"


func _draw() -> void:
	var active_color := Color("#e59b5e")
	if state == State.TELEGRAPH_RIPPLE:
		active_color = Color("#f6ca58")
	elif state == State.RIPPLE_ACTIVE or state == State.TELEGRAPH_PENDULUM or state == State.PENDULUM_ACTIVE:
		active_color = Color("#e97e70")
	elif state == State.STUNNED or state == State.CORE_EXPOSED:
		active_color = Color("#f6d65e")
	elif state == State.DEFEATED:
		active_color = Color("#ba9b79")
	if hit_flash_time > 0.0:
		active_color = Color("#fffce7")

	# Brass-and-candy shell.
	draw_circle(Vector2(0.0, 0.0), 49.0, active_color)
	draw_circle(Vector2(0.0, 0.0), 49.0, Color("#79594b"), false, 4.0, true)
	draw_rect(Rect2(Vector2(-31.0, -26.0), Vector2(62.0, 46.0)), Color("#c98050"), true)
	draw_rect(Rect2(Vector2(-31.0, -26.0), Vector2(62.0, 46.0)), Color("#79594b"), false, 3.0, true)
	for gear_x in [-34.0, 34.0]:
		draw_circle(Vector2(gear_x, 3.0), 16.0, Color("#f2ca67"))
		draw_circle(Vector2(gear_x, 3.0), 7.0, Color("#a8664d"))
	draw_circle(Vector2(-10.0, -8.0), 4.0, Color("#fff5d9"))
	draw_circle(Vector2(10.0, -8.0), 4.0, Color("#fff5d9"))
	draw_circle(Vector2(-10.0, -8.0), 2.0, Color("#5d4850"))
	draw_circle(Vector2(10.0, -8.0), 2.0, Color("#5d4850"))

	# The latch faces the approach lane; its glow becomes a clear target during telegraphs.
	var latch_color := Color("#fff1a7") if state in [State.TELEGRAPH_RIPPLE, State.TELEGRAPH_PENDULUM] else Color("#d7a64f")
	draw_circle(Vector2(-43.0, -20.0), 10.0, latch_color)
	draw_circle(Vector2(-43.0, -20.0), 10.0, Color("#79594b"), false, 2.5, true)

	if state == State.TELEGRAPH_RIPPLE:
		draw_arc(Vector2(0.0, 44.0), 30.0 + fmod(state_time * 20.0, 14.0), PI, TAU, 24, Color("#ffe077"), 5.0, true)
		draw_line(Vector2(-32.0, 50.0), Vector2(32.0, 50.0), Color("#f1b84d"), 4.0, true)
	elif state == State.RIPPLE_ACTIVE:
		draw_arc(Vector2(0.0, 44.0), ripple_radius, PI, TAU, 40, Color("#fff0b5"), 8.0, true)
	elif state == State.TELEGRAPH_PENDULUM or state == State.PENDULUM_ACTIVE:
		var tip := pendulum_tip() - global_position
		var alpha := 0.58 if state == State.TELEGRAPH_PENDULUM else 1.0
		draw_line(Vector2(0.0, -250.0), tip, Color(0.63, 0.35, 0.24, alpha), 7.0, true)
		draw_circle(tip, 24.0, Color("#d6a552"))
		draw_circle(tip, 24.0, Color("#7d5547"), false, 3.0, true)

	if is_core_open():
		draw_circle(Vector2(0.0, -35.0), 28.0, Color("#fff1a6", 0.58))
		draw_circle(Vector2(0.0, -35.0), 17.0, Color("#f7cc55"))
		draw_circle(Vector2(0.0, -35.0), 7.0, Color("#fffce4"))
	if state == State.DEFEATED:
		draw_line(Vector2(-26.0, -20.0), Vector2(-9.0, 0.0), Color("#6a4a47"), 4.0, true)
		draw_line(Vector2(25.0, -20.0), Vector2(8.0, 2.0), Color("#6a4a47"), 4.0, true)
