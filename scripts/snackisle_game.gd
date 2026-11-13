extends Node2D

const DUDU_TEXTURE: Texture2D = preload("res://assets/snackisle/dudu-512.png")
const POCHACCO_TEXTURE: Texture2D = preload("res://assets/snackisle/pochacco-512.png")
const DUDU_IDLE_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_idle.png")
const DUDU_RUN_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_run.png")
const DUDU_JUMP_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_jump.png")
const DUDU_ROLL_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_roll.png")
const DUDU_HURT_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_hurt.png")
const POCHACCO_IDLE_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/pochacco_idle.png")
const POCHACCO_RUN_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/pochacco_run.png")
const POCHACCO_JUMP_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/pochacco_jump.png")
const POCHACCO_ATTACK_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/pochacco_boomerang.png")
const POCHACCO_HURT_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/pochacco_hurt.png")
const DUDU_IDLE_FRAMES: Array[Texture2D] = [DUDU_IDLE_POSE, preload("res://assets/snackisle/animation_p0/dudu_idle_01.png"), preload("res://assets/snackisle/animation_p0/dudu_idle_02.png"), preload("res://assets/snackisle/animation_p0/dudu_idle_03.png")]
const DUDU_RUN_FRAMES: Array[Texture2D] = [DUDU_RUN_POSE, preload("res://assets/snackisle/animation_p0/dudu_run_01.png"), preload("res://assets/snackisle/animation_p0/dudu_run_02.png"), preload("res://assets/snackisle/animation_p0/dudu_run_03.png")]
const POCHACCO_IDLE_FRAMES: Array[Texture2D] = [POCHACCO_IDLE_POSE, preload("res://assets/snackisle/animation_p0/pochacco_idle_01.png"), preload("res://assets/snackisle/animation_p0/pochacco_idle_02.png"), preload("res://assets/snackisle/animation_p0/pochacco_idle_03.png")]
const POCHACCO_RUN_FRAMES: Array[Texture2D] = [POCHACCO_RUN_POSE, preload("res://assets/snackisle/animation_p0/pochacco_run_01.png"), preload("res://assets/snackisle/animation_p0/pochacco_run_02.png"), preload("res://assets/snackisle/animation_p0/pochacco_run_03.png")]
const DUDU_POUND_DROP_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_pound_01.png")
const DUDU_POUND_IMPACT_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_pound_02.png")
const DUDU_POUND_RECOVER_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_pound_03.png")
const DUDU_JUMP_FRAMES: Array[Texture2D] = [DUDU_JUMP_POSE]
const DUDU_ROLL_FRAMES: Array[Texture2D] = [DUDU_ROLL_POSE]
const DUDU_HURT_FRAMES: Array[Texture2D] = [DUDU_HURT_POSE]
const DUDU_POUND_DROP_FRAMES: Array[Texture2D] = [DUDU_POUND_DROP_POSE]
const DUDU_POUND_HIT_FRAMES: Array[Texture2D] = [DUDU_POUND_IMPACT_POSE, DUDU_POUND_RECOVER_POSE]
const DUDU_VICTORY_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/dudu_victory.png")
const POCHACCO_VICTORY_POSE: Texture2D = preload("res://assets/snackisle/animation_p0/pochacco_victory.png")
const DUDU_VICTORY_FRAMES: Array[Texture2D] = [DUDU_VICTORY_POSE]
const POCHACCO_JUMP_FRAMES: Array[Texture2D] = [POCHACCO_JUMP_POSE]
const POCHACCO_ATTACK_FRAMES: Array[Texture2D] = [POCHACCO_ATTACK_POSE]
const POCHACCO_HURT_FRAMES: Array[Texture2D] = [POCHACCO_HURT_POSE]
const POCHACCO_VICTORY_FRAMES: Array[Texture2D] = [POCHACCO_VICTORY_POSE]
const GAME_FONT: Font = preload("res://assets/template/fonts/ui_regular.tres")
const WORLD_WIDTH := 5200.0
const GROUND_Y := 620.0
const START_PLATFORM_TOP := 530.0
const GRAVITY := 1450.0
const DUDU_JUMP_SPEED := 560.0
const POCHACCO_JUMP_SPEED := 620.0
const DUDU_MOVE_SPEED := 235.0
const POCHACCO_MOVE_SPEED := 360.0
const DUDU_GROUND_ACCELERATION := 1400.0
const POCHACCO_GROUND_ACCELERATION := 1800.0
const DUDU_GROUND_FRICTION := 1800.0
const POCHACCO_GROUND_FRICTION := 2200.0
const DUDU_AIR_ACCELERATION := 800.0
const POCHACCO_AIR_ACCELERATION := 1050.0

var chapter_index := 1
var cloud_windmill_active := false
var cloud_gate
var cloud_windmill_x := 1650.0
var cloud_boss_x := 4250.0

var dudu
var pochacco
var camera: Camera2D
var hud_layer: CanvasLayer
var hud_root: Control
var hearts_view: Control
var stars_label: Label
var ingredients_label: Label
var chapter_label: Label
var objective_label: Label
var toast_label: Label
var bridge_platform
var team_gate
var hidden_wall
var bridge_cookie
var boss_gate
var dudu_selected := true
var health := 3
var star_candies := 0
var strawberry_ingredients := 0
var checkpoint_x := 160.0
var time_alive := 0.0
var toast_time := 0.0
var damage_cooldown := 0.0
var clues_visible := false
var clue_time := 0.0
var team_weight_activated := false
var team_hug_time := 0.0
var plate_pressed := false
var plate_hint_sent := false
var boss_defeated := false
var boss_exposed_time := 0.0
var boss_x := 4250.0
var boss_contact_cooldown := 0.0
var banana_peel_placed := false
var banana_peel_position := Vector2.ZERO
var bubble_positions: Array[Vector2] = [Vector2(2330, 536), Vector2(2510, 486), Vector2(2690, 536)]
var bubble_stun_times: Array[float] = [0.0, 0.0, 0.0]
var run_over := false
var pause_overlay: CanvasLayer
var result_overlay: CanvasLayer
var touch_controls: Control
var touch_joystick: SnackIsleTouchStick
var touch_buttons: Dictionary = {}
var touch_move_axis := 0.0
var touch_jump_pending := false
var last_ui_refresh := 0.0


class PastryPlatform extends StaticBody2D:
	var size := Vector2(200, 34)
	var flavor := "cake"
	var bouncy := false

	func _ready() -> void:
		collision_layer = 1
		collision_mask = 0
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = size
		shape.shape = rectangle
		add_child(shape)
		if bouncy:
			add_to_group("trampoline")
		add_to_group("pastry_platform")
		queue_redraw()

	func _draw() -> void:
		var bounds := Rect2(Vector2(-size.x * 0.5, -size.y * 0.5), size)
		var base := Color("#d89268")
		var icing := Color("#fff0d7")
		if flavor == "strawberry":
			base = Color("#f0ad91")
			icing = Color("#ffe5e6")
		elif flavor == "chocolate":
			base = Color("#80534f")
			icing = Color("#b87a73")
		elif flavor == "chiffon":
			base = Color("#f3ce6c")
			icing = Color("#fff6c7")
		elif flavor == "biscuit":
			base = Color("#dfae66")
			icing = Color("#ffdda1")
		elif flavor == "bridge":
			base = Color("#dca165")
			icing = Color("#fff1cb")
		elif flavor == "mint":
			base = Color("#a7d4bb")
			icing = Color("#e8f8df")
		elif flavor == "cloud":
			base = Color("#c6e5ed")
			icing = Color("#f8fff8")
		elif flavor == "wafer":
			base = Color("#dfc28b")
			icing = Color("#fff0c9")
		draw_rect(bounds, base, true)
		draw_rect(Rect2(bounds.position, Vector2(size.x, minf(13.0, size.y))), icing, true)
		draw_line(Vector2(bounds.position.x, bounds.position.y + 14), Vector2(bounds.end.x, bounds.position.y + 14), Color("#a7655d"), 3.0, true)
		var crumb_count := int(size.x / 52.0)
		for index in crumb_count:
			var crumb_x := bounds.position.x + 22.0 + float(index) * 48.0
			draw_circle(Vector2(crumb_x, bounds.position.y + minf(8.0, size.y * 0.3)), 2.4, Color("#fffaf0"))
		if flavor == "strawberry":
			for index in mini(5, crumb_count):
				draw_circle(Vector2(bounds.position.x + 30.0 + index * 54.0, bounds.position.y + 27.0), 4.5, Color("#d54b68"))
		if bouncy:
			draw_arc(Vector2(0, bounds.position.y + 2), minf(size.x * 0.37, 64.0), PI, TAU, 18, Color("#f08c78"), 4.0, true)


class PastryBlock extends StaticBody2D:
	var size := Vector2(48, 110)
	var kind := "hidden_wall"

	func _ready() -> void:
		collision_layer = 1
		collision_mask = 0
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(size.x, size.y + 18.0)
		shape.shape = rectangle
		shape.position.y = 9.0
		add_child(shape)
		add_to_group(kind)
		queue_redraw()

	func _draw() -> void:
		var bounds := Rect2(-size * 0.5, size)
		if kind == "hidden_wall":
			draw_rect(bounds, Color("#6f504c"), true)
			draw_rect(Rect2(bounds.position, Vector2(size.x, 12)), Color("#9a6e67"), true)
			for y in range(0, int(size.y), 24):
				draw_circle(Vector2(float(y % 2) * 7.0 - 6.0, bounds.position.y + y + 18.0), 2.0, Color("#b98979"))
		elif kind == "team_gate":
			draw_rect(bounds, Color("#e9a9a5"), true)
			draw_rect(Rect2(bounds.position, Vector2(size.x, 14)), Color("#fff1d2"), true)
			draw_circle(Vector2.ZERO, 13, Color("#f5cf6d"))
		elif kind == "cloud_gate":
			draw_rect(bounds, Color("#a9cfd7"), true)
			for cloud_x in [-16.0, 0.0, 16.0]:
				draw_circle(Vector2(cloud_x, -28), 17.0, Color("#f5fff7"))
				draw_circle(Vector2(cloud_x, 22), 17.0, Color("#f5fff7"))
			draw_circle(Vector2.ZERO, 8.0, Color("#e9bd5f"))
		else:
			draw_rect(bounds, Color("#d99a58"), true)
			draw_rect(Rect2(bounds.position, Vector2(size.x, 12)), Color("#fff1ce"), true)
			for x in range(-int(size.x * 0.35), int(size.x * 0.4), 14):
				draw_circle(Vector2(x, 4), 2.4, Color("#b97943"))


class StarCandy extends Area2D:
	var game
	var base_y := 0.0
	var phase := 0.0

	func _ready() -> void:
		collision_layer = 0
		collision_mask = 2
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 20.0
		shape.shape = circle
		add_child(shape)
		base_y = position.y
		body_entered.connect(_on_body_entered)

	func _process(delta: float) -> void:
		phase += delta
		position.y = base_y + sin(phase * 3.4) * 5.0
		queue_redraw()

	func _draw() -> void:
		var points := PackedVector2Array()
		for index in 10:
			var angle := -PI * 0.5 + float(index) * PI / 5.0
			var radius := 15.0 if index % 2 == 0 else 7.0
			points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
		draw_colored_polygon(points, Color("#ffd758"))
		draw_circle(Vector2(-3, -4), 2.6, Color("#fff8d6"))
		draw_circle(Vector2.ZERO, 16.0, Color(1.0, 1.0, 1.0, 0.0), false, 2.0, true)

	func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("snackisle_buddy") and game != null:
			game.collect_star(self)


class StrawberryFood extends Area2D:
	var game
	var kind := "strawberry"
	var base_y := 0.0
	var phase := 0.0

	func _ready() -> void:
		collision_layer = 0
		collision_mask = 2
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 17.0
		shape.shape = circle
		add_child(shape)
		base_y = position.y
		body_entered.connect(_on_body_entered)

	func _process(delta: float) -> void:
		phase += delta
		position.y = base_y + sin(phase * 2.8) * 4.0
		queue_redraw()

	func _draw() -> void:
		if kind == "cotton":
			draw_circle(Vector2(-7, 1), 9.0, Color("#f6c6db"))
			draw_circle(Vector2(2, -5), 10.0, Color("#fbe0ef"))
			draw_circle(Vector2(10, 1), 8.0, Color("#ecc0df"))
			draw_line(Vector2(0, 6), Vector2(1, 15), Color("#9ecbb1"), 3.0, true)
			draw_circle(Vector2(-4, -5), 2.0, Color("#fffdf2"))
			return
		var berry := PackedVector2Array([Vector2(0, 15), Vector2(-12, 4), Vector2(-12, -3), Vector2(-7, -9), Vector2(-2, -8), Vector2(0, -4), Vector2(4, -9), Vector2(10, -7), Vector2(12, 0), Vector2(8, 7)])
		draw_colored_polygon(berry, Color("#e85d72"))
		var leaves := PackedVector2Array([Vector2(-10, -7), Vector2(-5, -14), Vector2(-1, -8), Vector2(1, -15), Vector2(5, -8), Vector2(11, -9), Vector2(6, -3), Vector2(-5, -3)])
		draw_colored_polygon(leaves, Color("#81b98a"))
		for seed_position in [Vector2(-5, 1), Vector2(4, 2), Vector2(-1, 8)]:
			draw_circle(seed_position, 1.4, Color("#ffe8a4"))
		draw_circle(Vector2(-4, -1), 2.0, Color(1.0, 1.0, 1.0, 0.8))

	func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("snackisle_buddy") and game != null:
			game.collect_ingredient(self)


class BananaBoomerang extends Node2D:
	var game
	var direction := 1.0
	var start_position := Vector2.ZERO
	var elapsed := 0.0
	var hit_ids: Array[int] = []

	func _process(delta: float) -> void:
		elapsed += delta
		var flight := 0.48
		var progress := clampf(elapsed / flight, 0.0, 2.0)
		var outward := minf(progress, 1.0)
		var return_t := maxf(0.0, progress - 1.0)
		var travel := outward if progress <= 1.0 else 1.0 - return_t
		position = start_position + Vector2(direction * 310.0 * travel, -34.0 - sin(progress * PI) * 62.0)
		rotation = sin(elapsed * 23.0) * 0.4
		if game != null:
			game.check_boomerang_hit(self)
		queue_redraw()
		if elapsed >= flight * 2.0:
			queue_free()

	func _draw() -> void:
		var banana := PackedVector2Array([Vector2(-18, 6), Vector2(-13, -8), Vector2(-3, -14), Vector2(11, -10), Vector2(18, -2), Vector2(11, 2), Vector2(2, 0), Vector2(-5, 6), Vector2(-12, 11)])
		draw_colored_polygon(banana, Color("#f4cd4d"))
		draw_polyline(PackedVector2Array([Vector2(-15, 6), Vector2(-8, -2), Vector2(0, -5), Vector2(10, -3)]), Color("#d4943e"), 2.0, true)
		draw_circle(Vector2(-18, 6), 2.4, Color("#8b5a42"))
		draw_circle(Vector2(18, -2), 2.4, Color("#8b5a42"))


class MochiHearts extends Control:
	var health := 3:
		set(value):
			health = value
			queue_redraw()

	func _draw() -> void:
		for index in 3:
			var center := Vector2(20.0 + index * 34.0, 20.0)
			var full := index < health
			draw_circle(center, 13.0, Color("#ed8da5") if full else Color("#ead7d4"))
			draw_circle(center, 13.0, Color("#b54a66"), false, 2.0, true)
			if full:
				draw_circle(center + Vector2(-4, -2), 1.7, Color("#fff7df"))
				draw_circle(center + Vector2(4, -4), 1.7, Color("#fff7df"))
				draw_colored_polygon(PackedVector2Array([center + Vector2(-7, -10), center + Vector2(-1, -16), center + Vector2(2, -8)]), Color("#8dc77d"))
				draw_colored_polygon(PackedVector2Array([center + Vector2(-1, -10), center + Vector2(7, -15), center + Vector2(5, -7)]), Color("#6eae71"))
			else:
				draw_circle(center + Vector2(8, -8), 4.5, Color("#fffaf0"))
				draw_circle(center + Vector2(6, -10), 2.2, Color("#ef8da2"))


class SnackIsleTouchStick extends Control:
	signal axis_changed(value: float)
	signal jump_requested

	var pointer_id := -1
	var axis := Vector2.ZERO
	var knob_offset := Vector2.ZERO
	var jump_latched := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE
		custom_minimum_size = Vector2(132, 132)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			if event.pressed and pointer_id == -1:
				_begin_pointer(event.index, event.position)
			elif not event.pressed and event.index == pointer_id:
				_release_pointer()
		elif event is InputEventScreenDrag and event.index == pointer_id:
			_update_pointer(event.position)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and pointer_id == -1:
				_begin_pointer(-2, event.position)
			elif not event.pressed and pointer_id == -2:
				_release_pointer()
		elif event is InputEventMouseMotion and pointer_id == -2:
			_update_pointer(event.position)

	func _begin_pointer(pointer: int, point: Vector2) -> void:
		if not Rect2(Vector2.ZERO, size).has_point(point):
			return
		pointer_id = pointer
		_update_pointer(point)
		accept_event()

	func _update_pointer(point: Vector2) -> void:
		var radius := minf(size.x, size.y) * 0.34
		var displacement := point - size * 0.5
		var normalized := displacement / maxf(radius, 1.0)
		if normalized.length() > 1.0:
			normalized = normalized.normalized()
		axis = normalized
		knob_offset = axis * radius
		if axis.y < -0.66 and not jump_latched:
			jump_latched = true
			jump_requested.emit()
		elif axis.y > -0.35:
			jump_latched = false
		axis_changed.emit(axis.x)
		queue_redraw()
		accept_event()

	func _release_pointer() -> void:
		pointer_id = -1
		axis = Vector2.ZERO
		knob_offset = Vector2.ZERO
		jump_latched = false
		axis_changed.emit(0.0)
		queue_redraw()
		accept_event()

	func reset() -> void:
		if pointer_id != -1 or axis != Vector2.ZERO:
			_release_pointer()

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.43
		draw_circle(center, radius, Color(0.48, 0.29, 0.31, 0.22))
		draw_arc(center, radius, 0.0, TAU, 48, Color("#fff4e7", 0.9), 3.0, true)
		draw_line(center, center + knob_offset, Color("#fff4e7", 0.72), 4.0, true)
		draw_circle(center + knob_offset, radius * 0.43, Color("#f5d7c5", 0.94))
		draw_circle(center + knob_offset, radius * 0.43, Color("#a95e70", 0.88), false, 3.0, true)
		draw_circle(center + knob_offset + Vector2(-radius * 0.11, -radius * 0.11), radius * 0.08, Color("#fffaf1", 0.9))


class Buddy extends CharacterBody2D:
	var game
	var is_dudu := true
	var controlled := false
	var facing := 1.0
	var sprite: Sprite2D
	var anim_time := 0.0
	var roll_time := 0.0
	var hurt_pose_time := 0.0
	var action_pose_time := 0.0
	var pound_recovery_time := 0.0
	var pose_time := 0.0
	var active_pose := ""
	var victory_pose := false
	var ground_pounding := false
	var landing_lock := 0.0
	var squash_time := 0.0
	var moving_axis := 0.0
	var previous_floor := false
	var bounce_guard := 0.0
	var floor_probe: RayCast2D

	func jump_speed() -> float:
		return game.POCHACCO_JUMP_SPEED if not is_dudu else game.DUDU_JUMP_SPEED

	func move_speed() -> float:
		return game.POCHACCO_MOVE_SPEED if not is_dudu else game.DUDU_MOVE_SPEED

	func ground_acceleration() -> float:
		return game.POCHACCO_GROUND_ACCELERATION if not is_dudu else game.DUDU_GROUND_ACCELERATION

	func ground_friction() -> float:
		return game.POCHACCO_GROUND_FRICTION if not is_dudu else game.DUDU_GROUND_FRICTION

	func air_acceleration() -> float:
		return game.POCHACCO_AIR_ACCELERATION if not is_dudu else game.DUDU_AIR_ACCELERATION

	func _ready() -> void:
		add_to_group("snackisle_buddy")
		collision_layer = 2
		collision_mask = 1
		var hitbox := CollisionShape2D.new()
		var capsule := CapsuleShape2D.new()
		capsule.radius = 18.0
		capsule.height = 54.0
		hitbox.shape = capsule
		add_child(hitbox)
		floor_probe = RayCast2D.new()
		floor_probe.collision_mask = 1
		add_child(floor_probe)
		sprite = Sprite2D.new()
		sprite.texture = game.texture_for(is_dudu)
		sprite.scale = Vector2.ONE * 0.17
		sprite.position = Vector2(0, -4)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(sprite)
		queue_redraw()

	func _physics_process(delta: float) -> void:
		if game == null or game.run_over:
			return
		anim_time += delta
		roll_time = maxf(0.0, roll_time - delta)
		landing_lock = maxf(0.0, landing_lock - delta)
		bounce_guard = maxf(0.0, bounce_guard - delta)
		var direction := clampf(Input.get_axis("move_left", "move_right") + game.touch_move_axis, -1.0, 1.0) if controlled else _follow_axis()
		moving_axis = direction
		if absf(direction) > 0.05:
			facing = signf(direction)
		var on_floor_before := is_on_floor()
		if on_floor_before:
			velocity.y = maxf(velocity.y, 0.0)
		else:
			velocity.y += game.GRAVITY * delta
			if game.is_cloud_updraft(global_position.x):
				velocity.y -= 430.0 * delta
		var touch_jump: bool = game.consume_touch_jump() if controlled else false
		if controlled and (Input.is_action_just_pressed("jump") or touch_jump) and on_floor_before and landing_lock <= 0.0:
			velocity.y = -jump_speed()
			game.on_jump(self)
		if controlled and is_dudu and Input.is_action_just_pressed("ground_pound"):
			start_ground_pound()
		if controlled and Input.is_action_just_pressed("attack"):
			game.perform_attack(self)
		if controlled and not is_dudu and Input.is_action_just_pressed("sniff"):
			game.detect_clues()
		if controlled and not is_dudu and Input.is_action_just_pressed("drop_peel"):
			game.drop_banana_peel(self)
		var speed := move_speed()
		if roll_time > 0.0 and is_dudu:
			speed = 630.0
		elif not controlled and is_dudu and game.active_is_pochacco() and game.follow_gap(self) > 320.0:
			roll_time = 0.6
			speed = 630.0
		if game.is_mousse(global_position.x):
			speed *= 0.48
		if absf(direction) > 0.05:
			velocity.x = move_toward(velocity.x, direction * speed, ground_acceleration() * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, ground_friction() * delta)
		var incoming_y := velocity.y
		move_and_slide()
		if global_position.y > 820.0:
			game.fall_to_safety(self)
			return
		if not on_floor_before and is_on_floor() and incoming_y > 180.0:
			var did_bounce := false
			var landed_on_trampoline := false
			for index in get_slide_collision_count():
				var hit := get_slide_collision(index)
				var collider: Object = hit.get_collider()
				if collider is Node and collider.is_in_group("trampoline"):
					landed_on_trampoline = true
				break
				if ground_pounding:
					ground_pounding = false
					pound_recovery_time = 0.28
					active_pose = ""
					game.resolve_ground_pound(self)
			if landed_on_trampoline and bounce_guard <= 0.0:
				velocity.y = -690.0
				bounce_guard = 0.3
				did_bounce = true
				game.on_trampoline(self)
			if not did_bounce:
				landing_lock = 0.06
		for index in get_slide_collision_count():
			var hit := get_slide_collision(index)
			var collider: Object = hit.get_collider()
			if collider is Node and hit.get_normal().x != 0.0:
				if collider.is_in_group("hidden_wall"):
					if is_dudu and roll_time > 0.0:
						game.break_barrier(collider)
					else:
						game.show_toast("前方有一面巧克力牆；讓帕恰狗先嗅聞線索！")
				elif collider.is_in_group("team_gate"):
					game.show_toast("先讓嘟嘟站上大福按鈕，再按 Y／F 集合！")
				elif collider.is_in_group("bridge_cookie"):
					if is_dudu and roll_time > 0.0 and game.plate_is_held():
						game.break_barrier(collider)
					else:
						game.show_toast("帕恰狗要留在雲朵踏板上喔！" if game.chapter_index == 2 else "帕恰狗要留在果醬河控制踏板上喔！")
				elif collider.is_in_group("cloud_gate"):
					game.show_toast("先讓帕恰狗用香蕉迴旋鏢敲響雲朵風車！")
				elif collider.is_in_group("boss_gate") and not game.boss_defeated:
					game.show_toast("用帕恰狗的香蕉迴旋鏢敲暈雲朵風靈，再讓嘟嘟屁屁坐擊！" if game.chapter_index == 2 else "先讓奶油怪踩上香蕉皮，再用嘟嘟屁屁坐擊！")
		if absf(velocity.x) > 0.1 and not is_on_floor():
			velocity.x = move_toward(velocity.x, direction * speed, air_acceleration() * delta)
		if is_on_floor() and ground_pounding:
			ground_pounding = false
			pound_recovery_time = 0.28
			active_pose = ""
		game.on_buddy_moved(self)
		queue_redraw()

	func _process(delta: float) -> void:
		if sprite == null:
			return
		var moving := absf(velocity.x) > 38.0
		sprite.flip_h = facing < 0.0
		squash_time = maxf(0.0, squash_time - delta)
		hurt_pose_time = maxf(0.0, hurt_pose_time - delta)
		action_pose_time = maxf(0.0, action_pose_time - delta)
		pound_recovery_time = maxf(0.0, pound_recovery_time - delta)
		var pose := "idle"
		if victory_pose:
			pose = "victory"
		elif hurt_pose_time > 0.0:
			pose = "hurt"
		elif is_dudu and roll_time > 0.0:
			pose = "roll"
		elif action_pose_time > 0.0:
			pose = "attack"
		elif is_dudu and ground_pounding:
			pose = "pound_drop"
		elif is_dudu and pound_recovery_time > 0.0:
			pose = "pound_hit"
		elif not is_on_floor():
			pose = "jump"
		elif moving:
			pose = "run"
		if pose != active_pose:
			active_pose = pose
			pose_time = 0.0
		else:
			pose_time += delta
		var frames := game.pose_frames_for(is_dudu, pose)
		var frame_index := int(floor(pose_time * game.pose_fps_for(pose)))
		if pose == "pound_hit":
			frame_index = mini(frame_index, frames.size() - 1)
		else:
			frame_index %= frames.size()
		sprite.texture = frames[frame_index]
		var squash := Vector2.ONE
		if victory_pose:
			sprite.rotation = 0.0
		elif roll_time > 0.0 and is_dudu:
			squash = Vector2(1.24, 0.72)
			sprite.rotation += facing * delta * 15.0
		else:
			sprite.rotation = sin(anim_time * 7.0) * (0.025 if moving else 0.012)
			if is_on_floor() and moving:
				squash.y += sin(anim_time * 17.0) * 0.035
		if squash_time > 0.0 and not victory_pose:
			squash *= Vector2(1.13, 0.74)
		sprite.scale = Vector2.ONE * 0.17 * squash
		queue_redraw()

	func _draw() -> void:
		if is_dudu and is_on_floor() and absf(velocity.x) < 24.0 and fmod(anim_time, 5.2) > 4.2:
			draw_circle(Vector2(-23, -55), 6.0, Color("#d9a354"))
			draw_circle(Vector2(-25, -58), 1.8, Color("#fff0b9"))
		elif not is_dudu and is_on_floor() and absf(velocity.x) < 24.0:
			var wing := 4.0 + sin(anim_time * 9.0) * 2.0
			draw_circle(Vector2(28, -56), wing, Color("#ffd870"))
			draw_circle(Vector2(35, -58), wing, Color("#f393ab"))

	func _follow_axis() -> float:
		var leader = game.get_active_buddy()
		if leader == null or leader == self:
			return 0.0
		if not is_dudu and game.plate_pressed and game.active_is_dudu() and absf(global_position.x - game.plate_x) < 110.0:
			return 0.0
		var gap: float = leader.global_position.x - global_position.x
		if absf(gap) < (58.0 if is_dudu else 72.0):
			return 0.0
		var direction := signf(gap)
		if is_on_floor():
			floor_probe.target_position = Vector2(direction * 42.0, 72.0)
			floor_probe.force_raycast_update()
			var floor_exists := floor_probe.is_colliding()
			if not floor_exists:
				velocity.y = -jump_speed() * 0.9
				game.on_jump(self)
			elif leader.global_position.y < global_position.y - 48.0:
				velocity.y = -jump_speed() * 0.92
				game.on_jump(self)
		return direction

	func start_ground_pound() -> void:
		if not is_dudu:
			return
		if is_on_floor():
			game.show_toast("先跳起來，再按 X／K 使出屁屁坐擊！")
			return
		ground_pounding = true
		velocity.y = 1050.0
		velocity.x = facing * 70.0
		game.show_toast("屁屁坐擊！粉紅震波準備發射！")

	func begin_roll() -> void:
		if not is_dudu:
			return
		roll_time = 0.72
		velocity.x = facing * 630.0
		squash_time = 0.18

	func receive_bounce() -> void:
		squash_time = 0.22
		velocity.x = -facing * 165.0
		velocity.y = -210.0

	func receive_soft_hit() -> void:
		squash_time = 0.48
		hurt_pose_time = 0.34
		velocity.x = -facing * 200.0
		velocity.y = -250.0


func _ready() -> void:
	chapter_index = clampi(int(get_tree().get_meta("snackisle_chapter", 1)), 1, 2)
	_ensure_input_actions()
	build_world()
	spawn_buddies()
	build_camera()
	build_hud()
	show_toast(_l10n("章二開場提示") if chapter_index == 2 else "怪盜喵嗚偷走了噴泉閥門！沿地面靠近戚風蛋糕，再讓嘟嘟跳上去收集星星糖。")
	_update_objective()
	queue_redraw()


func _ensure_input_actions() -> void:
	_ensure_action_keys("switch_character", [KEY_TAB, KEY_L])
	_ensure_action_keys("sniff", [KEY_E])
	_ensure_action_keys("ground_pound", [KEY_K])
	_ensure_action_keys("assemble", [KEY_F])
	_ensure_action_keys("drop_peel", [KEY_C])
	_ensure_action_keys("pause_game", [KEY_ESCAPE])
	_ensure_action_keys("guide_or_peel", [KEY_R])
	_ensure_action_joypad_button("jump", JOY_BUTTON_A)
	_ensure_action_joypad_button("attack", JOY_BUTTON_B)
	_ensure_action_joypad_button("ground_pound", JOY_BUTTON_X)
	_ensure_action_joypad_button("sniff", JOY_BUTTON_X)
	_ensure_action_joypad_button("assemble", JOY_BUTTON_Y)
	_ensure_action_joypad_button("switch_character", JOY_BUTTON_LEFT_SHOULDER)
	_ensure_action_joypad_button("guide_or_peel", JOY_BUTTON_RIGHT_SHOULDER)
	_ensure_action_joypad_button("pause_game", JOY_BUTTON_START)


func _ensure_action_keys(action_name: String, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key_code in keys:
		var already_bound := false
		for event in InputMap.action_get_events(action_name):
			if event is InputEventKey and event.physical_keycode == int(key_code):
				already_bound = true
				break
		if not already_bound:
				var key_event := InputEventKey.new()
				key_event.physical_keycode = int(key_code)
				InputMap.action_add_event(action_name, key_event)


func _ensure_action_joypad_button(action_name: String, button_index: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return
	var joypad_event := InputEventJoypadButton.new()
	joypad_event.button_index = button_index
	InputMap.action_add_event(action_name, joypad_event)


func _l10n(value: String, placeholders: Dictionary = {}) -> String:
	return get_node("/root/I18n").t(value, placeholders)


func _chapter_title() -> String:
	return _l10n("第二章｜棉花糖雲朵森林") if chapter_index == 2 else _l10n("第一章｜草莓蛋糕村")


func texture_for(is_dudu: bool) -> Texture2D:
	return DUDU_TEXTURE if is_dudu else POCHACCO_TEXTURE

func pose_frames_for(is_dudu: bool, pose: String) -> Array[Texture2D]:
	if is_dudu:
		match pose:
			"idle": return DUDU_IDLE_FRAMES
			"run": return DUDU_RUN_FRAMES
			"jump": return DUDU_JUMP_FRAMES
			"roll": return DUDU_ROLL_FRAMES
			"hurt": return DUDU_HURT_FRAMES
			"pound_drop": return DUDU_POUND_DROP_FRAMES
			"pound_hit": return DUDU_POUND_HIT_FRAMES
			"victory": return DUDU_VICTORY_FRAMES
	else:
		match pose:
			"idle": return POCHACCO_IDLE_FRAMES
			"run": return POCHACCO_RUN_FRAMES
			"jump": return POCHACCO_JUMP_FRAMES
			"attack": return POCHACCO_ATTACK_FRAMES
			"hurt": return POCHACCO_HURT_FRAMES
			"victory": return POCHACCO_VICTORY_FRAMES
	return DUDU_IDLE_FRAMES if is_dudu else POCHACCO_IDLE_FRAMES


func pose_fps_for(pose: String) -> float:
	match pose:
		"idle": return 5.0
		"run": return 10.0
		"pound_hit": return 8.0
	return 1.0


func build_world() -> void:
	if chapter_index == 2:
		_build_cloud_world()
		return
	_add_platform(0, GROUND_Y, 2120, 220, "strawberry")
	_add_platform(2720, GROUND_Y, 330, 220, "cake")
	_add_platform(3380, GROUND_Y, 1820, 220, "strawberry")
	_add_platform(500, START_PLATFORM_TOP, 185, 26, "chiffon", true)
	_add_platform(735, 410, 175, 25, "biscuit")
	_add_platform(1210, 525, 165, 24, "chocolate")
	_add_platform(1780, 505, 170, 24, "biscuit")
	_add_platform(2190, 548, 174, 24, "biscuit")
	_add_platform(2398, 496, 158, 24, "strawberry")
	_add_platform(2594, 548, 178, 24, "biscuit")
	_add_platform(3930, 505, 190, 24, "biscuit")
	_add_platform(bridge_start_x(), 475, 340, 24, "bridge")
	bridge_platform = get_child(get_child_count() - 1)
	team_gate = _add_barrier(1050, 545, Vector2(46, 150), "team_gate")
	hidden_wall = _add_barrier(1560, 545, Vector2(54, 150), "hidden_wall")
	bridge_cookie = _add_barrier(3068, 548, Vector2(54, 140), "bridge_cookie")
	boss_gate = _add_barrier(4650, 545, Vector2(44, 150), "boss_gate")
	_add_star(Vector2(420, 525))
	_add_star(Vector2(510, 455))
	_add_star(Vector2(625, 436))
	_add_star(Vector2(766, 372))
	_add_star(Vector2(855, 360))
	_add_star(Vector2(1160, 565))
	_add_star(Vector2(1245, 487))
	_add_star(Vector2(1370, 545))
	_add_star(Vector2(1735, 485))
	_add_star(Vector2(1930, 475))
	_add_star(Vector2(2226, 512))
	_add_star(Vector2(2440, 458))
	_add_star(Vector2(2660, 510))
	_add_star(Vector2(2850, 570))
	_add_star(Vector2(2980, 555))
	_add_star(Vector2(3475, 550))
	_add_star(Vector2(3710, 535))
	_add_star(Vector2(4025, 462))
	_add_star(Vector2(4475, 540))
	_add_star(Vector2(4840, 535))
	_add_ingredient(Vector2(690, 430))
	_add_ingredient(Vector2(1835, 560))
	_add_ingredient(Vector2(2230, 507))
	_add_ingredient(Vector2(4010, 462))
	plate_x = 2940.0


func _build_cloud_world() -> void:
	_add_platform(0, GROUND_Y, 980, 220, "mint")
	_add_platform(1260, GROUND_Y, 830, 220, "mint")
	_add_platform(2380, GROUND_Y, 900, 220, "mint")
	_add_platform(3650, GROUND_Y, 1550, 220, "mint")
	_add_platform(420, 500, 190, 26, "cloud", true)
	_add_platform(730, 420, 180, 24, "wafer")
	_add_platform(1030, 500, 180, 24, "cloud", true)
	_add_platform(1320, 500, 200, 24, "cloud")
	_add_platform(1570, 455, 180, 24, "wafer")
	_add_platform(2040, 505, 180, 24, "cloud", true)
	_add_platform(2150, 465, 190, 24, "cloud")
	_add_platform(2310, 515, 165, 24, "wafer")
	_add_platform(2510, 510, 185, 24, "cloud", true)
	_add_platform(2800, 448, 190, 24, "wafer")
	_add_platform(3060, 500, 180, 24, "cloud")
	cloud_windmill_x = 1650.0
	cloud_gate = _add_barrier(1920, 545, Vector2(48, 160), "cloud_gate")
	plate_x = 3160.0
	bridge_start = 3280.0
	_add_platform(bridge_start, 475, 370, 24, "cloud")
	bridge_platform = get_child(get_child_count() - 1)
	bridge_cookie = _add_barrier(3465, 548, Vector2(52, 140), "bridge_cookie")
	boss_gate = _add_barrier(4660, 545, Vector2(44, 150), "boss_gate")
	cloud_windmill_active = false
	plate_pressed = false
	boss_x = cloud_boss_x
	bubble_positions = [Vector2(2680, 520), Vector2(3900, 530), Vector2(4060, 475)]
	bubble_stun_times = [0.0, 0.0, 0.0]
	for pos in [Vector2(390, 525), Vector2(510, 465), Vector2(770, 375), Vector2(1050, 462), Vector2(1350, 470), Vector2(1640, 420), Vector2(2080, 468), Vector2(2300, 477), Vector2(2540, 465), Vector2(2835, 395), Vector2(3090, 465), Vector2(3320, 445), Vector2(3780, 540), Vector2(4020, 455), Vector2(4480, 520), Vector2(4870, 530)]:
		_add_star(pos)
	for pos in [Vector2(820, 382), Vector2(1450, 455), Vector2(2550, 470), Vector2(3000, 460), Vector2(4080, 490)]:
		_add_ingredient(pos, "cotton")


var plate_x := 2940.0
var bridge_start := 3050.0


func bridge_start_x() -> float:
	return bridge_start


func _add_platform(start_x: float, top_y: float, width: float, height: float, flavor: String, bouncy := false):
	var platform := PastryPlatform.new()
	platform.size = Vector2(width, height)
	platform.flavor = flavor
	platform.bouncy = bouncy
	platform.position = Vector2(start_x + width * 0.5, top_y + height * 0.5)
	add_child(platform)
	return platform


func _add_barrier(x: float, center_y: float, dimensions: Vector2, kind: String):
	var block := PastryBlock.new()
	block.size = dimensions
	block.kind = kind
	block.position = Vector2(x, center_y)
	add_child(block)
	return block


func _add_star(pos: Vector2) -> void:
	var candy := StarCandy.new()
	candy.game = self
	candy.position = pos
	add_child(candy)


func _add_ingredient(pos: Vector2, kind := "strawberry") -> void:
	var ingredient := StrawberryFood.new()
	ingredient.game = self
	ingredient.kind = kind
	ingredient.position = pos
	add_child(ingredient)


func spawn_buddies() -> void:
	dudu = Buddy.new()
	dudu.name = "Dudu"
	dudu.game = self
	dudu.is_dudu = true
	dudu.position = Vector2(150, GROUND_Y - 27)
	add_child(dudu)
	pochacco = Buddy.new()
	pochacco.name = "Pochacco"
	pochacco.game = self
	pochacco.is_dudu = false
	pochacco.position = Vector2(82, GROUND_Y - 27)
	add_child(pochacco)
	_update_controlled_state()


func build_camera() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.position = Vector2(640, 360)
	add_child(camera)
	camera.make_current()


func build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 10
	add_child(hud_layer)
	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(hud_root)
	var top_panel := PanelContainer.new()
	top_panel.name = "NotebookHUD"
	top_panel.position = Vector2(14, 12)
	top_panel.custom_minimum_size = Vector2(280, 106)
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_panel(top_panel, Color(1.0, 0.976, 0.89, 0.95), Color("#d39a87"))
	hud_root.add_child(top_panel)
	var left_stack := VBoxContainer.new()
	left_stack.add_theme_constant_override("separation", 0)
	left_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_panel.add_child(left_stack)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 7)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_stack.add_child(top_row)
	hearts_view = MochiHearts.new()
	hearts_view.custom_minimum_size = Vector2(110, 42)
	hearts_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(hearts_view)
	var backpack := Label.new()
	backpack.text = _l10n("小雞背包")
	backpack.add_theme_font_size_override("font_size", 15)
	backpack.add_theme_color_override("font_color", Color("#94704c"))
	backpack.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_row.add_child(backpack)
	var inventory_row := HBoxContainer.new()
	inventory_row.name = "InventoryCounts"
	inventory_row.add_theme_constant_override("separation", 5)
	inventory_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var candy_icon := Label.new()
	candy_icon.text = "★"
	candy_icon.add_theme_font_size_override("font_size", 17)
	candy_icon.add_theme_color_override("font_color", Color("#e9b84d"))
	inventory_row.add_child(candy_icon)
	stars_label = Label.new()
	stars_label.text = _l10n("星星糖 {count}", {"count": "00"})
	stars_label.add_theme_font_size_override("font_size", 14)
	stars_label.add_theme_color_override("font_color", Color("#694d50"))
	stars_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_row.add_child(stars_label)
	ingredients_label = Label.new()
	ingredients_label.text = _l10n("食材 {count}", {"count": "00"})
	ingredients_label.add_theme_font_size_override("font_size", 14)
	ingredients_label.add_theme_color_override("font_color", Color("#694d50"))
	ingredients_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_row.add_child(ingredients_label)
	left_stack.add_child(inventory_row)
	chapter_label = Label.new()
	chapter_label.name = "GameChapter"
	chapter_label.text = _chapter_title()
	chapter_label.add_theme_font_size_override("font_size", 14)
	chapter_label.add_theme_color_override("font_color", Color("#ac6371"))
	left_stack.add_child(chapter_label)
	objective_label = Label.new()
	objective_label.name = "Objective"
	objective_label.text = _l10n("尋回草莓噴泉閥門")
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.add_theme_font_size_override("font_size", 17)
	objective_label.add_theme_color_override("font_color", Color("#674850"))
	objective_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	objective_label.offset_left = 340
	objective_label.offset_right = -110
	objective_label.offset_top = 16
	objective_label.offset_bottom = 66
	objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(objective_label)
	var pause_button := _make_button("Ⅱ", 50, 46, false)
	pause_button.name = "PauseButton"
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -65
	pause_button.offset_top = 13
	pause_button.offset_right = -14
	pause_button.offset_bottom = 61
	pause_button.pressed.connect(open_pause)
	hud_root.add_child(pause_button)
	toast_label = Label.new()
	toast_label.name = "SnackToast"
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_font_size_override("font_size", 20)
	toast_label.add_theme_color_override("font_color", Color("#754957"))
	toast_label.add_theme_color_override("font_outline_color", Color("#fff8ec"))
	toast_label.add_theme_constant_override("outline_size", 4)
	toast_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	toast_label.offset_left = 80
	toast_label.offset_right = -80
	toast_label.offset_top = 124
	toast_label.offset_bottom = 164
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(toast_label)
	_build_touch_controls()
	get_viewport().size_changed.connect(_layout_hud)
	_layout_hud()


func _style_panel(panel: PanelContainer, fill: Color, border: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.shadow_color = Color(0.35, 0.15, 0.18, 0.16)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 3)
	panel.add_theme_stylebox_override("panel", style)


func _make_button(text_value: String, width: float, height: float, primary: bool) -> Button:
	var button := Button.new()
	button.text = _l10n(text_value)
	button.custom_minimum_size = Vector2(width, height)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("#69464f"))
	button.add_theme_color_override("font_hover_color", Color("#8e4358"))
	button.add_theme_color_override("font_pressed_color", Color("#fff8ec"))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#ec92a7") if primary else Color("#fff5db")
		if state == "hover":
			style.bg_color = Color("#f2a4b3") if primary else Color("#ffeecc")
		elif state == "pressed":
			style.bg_color = Color("#d76c89") if primary else Color("#f5d9a3")
		style.border_color = Color("#b95d73")
		style.set_border_width_all(2)
		style.set_corner_radius_all(15)
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		button.add_theme_stylebox_override(state, style)
	return button


func _make_touch_pad_button(key: String, text_value: String) -> Button:
	var button := _make_button(text_value, 60, 60, false)
	button.name = "Touch" + key
	button.focus_mode = Control.FOCUS_NONE
	button.set_meta("pad_key", key)
	touch_buttons[key] = button
	_style_touch_pad_button(button, key, 60.0, key == "L" or key == "R")
	return button


func _touch_pad_spacer(node_name: String) -> Control:
	var spacer := Control.new()
	spacer.name = node_name
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _style_touch_pad_button(button: Button, key: String, cell: float, shoulder: bool = false) -> void:
	var base_color := Color("#f1b7c3")
	match key:
		"A": base_color = Color("#9bd3a5")
		"B": base_color = Color("#ee8791")
		"X": base_color = Color("#8cc7e8")
		"Y": base_color = Color("#f2cf68")
	button.add_theme_color_override("font_color", Color("#62434b"))
	button.add_theme_color_override("font_hover_color", Color("#70404b"))
	button.add_theme_color_override("font_pressed_color", Color("#fffaf2"))
	var corner_radius := 12 if shoulder else roundi(cell * 0.5)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var fill := base_color
		if state == "hover":
			fill = base_color.lightened(0.08)
		elif state == "pressed":
			fill = base_color.darkened(0.12)
		var style := StyleBoxFlat.new()
		style.bg_color = fill
		style.border_color = base_color.darkened(0.28)
		style.set_border_width_all(2)
		style.set_corner_radius_all(corner_radius)
		style.content_margin_left = 2
		style.content_margin_right = 2
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		style.shadow_color = Color(0.35, 0.15, 0.18, 0.18)
		style.shadow_size = 2
		style.shadow_offset = Vector2(0, 2)
		button.add_theme_stylebox_override(state, style)


func _build_touch_controls() -> void:
	touch_controls = Control.new()
	touch_controls.name = "PwaTouchControls"
	touch_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	touch_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(touch_controls)
	touch_joystick = SnackIsleTouchStick.new()
	touch_joystick.name = "TouchJoystick"
	touch_joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	touch_joystick.axis_changed.connect(_set_touch_move_axis)
	touch_joystick.jump_requested.connect(_request_touch_jump)
	touch_controls.add_child(touch_joystick)
	var grid := GridContainer.new()
	grid.name = "ActionGrid"
	grid.columns = 3
	grid.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grid.offset_left = -206
	grid.offset_top = -130
	grid.offset_right = -12
	grid.offset_bottom = -12
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	touch_controls.add_child(grid)
	var left_button := _make_touch_pad_button("L", "L\n切換")
	left_button.pressed.connect(switch_character)
	grid.add_child(left_button)
	grid.add_child(_touch_pad_spacer("PadSpacerTop"))
	var right_button := _make_touch_pad_button("R", "R\n攻略")
	right_button.pressed.connect(_touch_r_action)
	grid.add_child(right_button)
	grid.add_child(_touch_pad_spacer("PadSpacerYLeft"))
	var y_button := _make_touch_pad_button("Y", "Y\n抱抱")
	y_button.pressed.connect(request_gather)
	grid.add_child(y_button)
	grid.add_child(_touch_pad_spacer("PadSpacerYRight"))
	var x_button := _make_touch_pad_button("X", "X\n坐擊")
	x_button.pressed.connect(_touch_special)
	grid.add_child(x_button)
	grid.add_child(_touch_pad_spacer("PadSpacerXB"))
	var b_button := _make_touch_pad_button("B", "B\n滾動")
	b_button.pressed.connect(_touch_attack)
	grid.add_child(b_button)
	grid.add_child(_touch_pad_spacer("PadSpacerABLeft"))
	var a_button := _make_touch_pad_button("A", "A\n跳躍")
	_hold_action(a_button, "jump")
	grid.add_child(a_button)
	grid.add_child(_touch_pad_spacer("PadSpacerABRight"))
	_layout_hud()


func _hold_action(button: Button, action: String) -> void:
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	button.mouse_exited.connect(func(): Input.action_release(action))


func _set_touch_move_axis(value: float) -> void:
	if run_over or is_instance_valid(pause_overlay):
		touch_move_axis = 0.0
	else:
		touch_move_axis = clampf(value, -1.0, 1.0)


func _request_touch_jump() -> void:
	if not run_over and not is_instance_valid(pause_overlay):
		touch_jump_pending = true


func consume_touch_jump() -> bool:
	var requested := touch_jump_pending
	touch_jump_pending = false
	return requested


func _clear_touch_input() -> void:
	touch_move_axis = 0.0
	touch_jump_pending = false
	if is_instance_valid(touch_joystick):
		touch_joystick.reset()


func _layout_hud() -> void:
	if hud_root == null:
		return
	var view_size := get_viewport_rect().size
	var narrow := view_size.x < 560.0
	if is_instance_valid(objective_label):
		objective_label.offset_left = 325.0 if not narrow else 304.0
		objective_label.offset_right = -86.0
		objective_label.offset_top = 13.0
		objective_label.offset_bottom = 69.0
		objective_label.add_theme_font_size_override("font_size", 14 if narrow else 17)
	if touch_controls != null:
		var touch := DisplayServer.is_touchscreen_available() or view_size.x < 900.0
		touch_controls.visible = touch
		var button_size := 42.0 if view_size.x < 400.0 else (54.0 if view_size.x < 850.0 else 68.0)
		var stick_size := clampf(button_size * 2.45, 112.0, 156.0)
		touch_joystick.offset_left = 12.0
		touch_joystick.offset_top = -stick_size - 12.0
		touch_joystick.offset_right = 12.0 + stick_size
		touch_joystick.offset_bottom = -12.0
		var grid := touch_controls.get_node("ActionGrid") as GridContainer
		var cell := button_size if button_size <= 54.0 else 60.0
		var grid_width := cell * 3.0 + 8.0
		var grid_height := cell * 4.0 + 12.0
		grid.offset_left = -grid_width - 12.0
		grid.offset_top = -grid_height - 12.0
		grid.offset_right = -12.0
		grid.offset_bottom = -12.0
		for child in grid.get_children():
			if not child is Button:
				continue
			var button := child as Button
			var key := str(button.get_meta("pad_key", ""))
			button.custom_minimum_size = Vector2(cell, cell)
			button.add_theme_font_size_override("font_size", 10 if cell <= 42.0 else (12 if cell <= 54.0 else 14))
			_style_touch_pad_button(button, key, cell, key == "L" or key == "R")
		_refresh_touch_labels()


func _refresh_touch_labels() -> void:
	if touch_buttons.is_empty():
		return
	var labels := {
		"A": "A\n跳躍",
		"B": "B\n滾動" if active_is_dudu() else "B\n迴旋",
		"X": "X\n坐擊" if active_is_dudu() else "X\n嗅嗅",
		"Y": "Y\n抱抱",
		"L": "L\n切換",
		"R": "R\n攻略" if active_is_dudu() else "R\n蕉皮",
	}
	var descriptions := {
		"A": "A｜跳躍",
		"B": "B｜嘟嘟滾滾衝刺" if active_is_dudu() else "B｜帕恰狗香蕉迴旋鏢",
		"X": "X｜嘟嘟屁屁坐擊" if active_is_dudu() else "X｜帕恰狗偵探嗅嗅",
		"Y": "Y｜集合抱抱",
		"L": "L｜切換角色",
		"R": "R｜嘟嘟開啟攻略說明" if active_is_dudu() else "R｜帕恰狗放香蕉皮",
	}
	for key in labels:
		var button := touch_buttons[key] as Button
		button.text = _l10n(labels[key])
		button.tooltip_text = _l10n(descriptions[key])
		button.accessibility_name = _l10n(descriptions[key])


func _update_controlled_state() -> void:
	if is_instance_valid(dudu):
		dudu.controlled = active_is_dudu()
	if is_instance_valid(pochacco):
		pochacco.controlled = not active_is_dudu()
	_refresh_touch_labels()
	_update_objective()


func active_is_dudu() -> bool:
	return dudu_selected


func active_is_pochacco() -> bool:
	return not dudu_selected


func get_active_buddy():
	return dudu if active_is_dudu() else pochacco


func switch_character() -> void:
	if run_over:
		return
	dudu_selected = not dudu_selected
	_update_controlled_state()
	if camera != null:
		camera.global_position.x = get_active_buddy().global_position.x
	show_toast(_l10n("現在由{name}帶隊！", {"name": "嘟嘟" if active_is_dudu() else "帕恰狗"}))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("switch_character"):
		switch_character()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("assemble"):
		request_gather()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("guide_or_peel"):
		_touch_r_action()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause_game"):
		if is_instance_valid(pause_overlay):
			resume_game()
		else:
			open_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		if is_instance_valid(pause_overlay):
			resume_game()
			get_viewport().set_input_as_handled()
		elif not event.is_action_pressed("attack"):
			open_pause()
			get_viewport().set_input_as_handled()


func perform_attack(buddy: Buddy) -> void:
	if buddy.is_dudu:
		buddy.begin_roll()
		show_toast("嘟嘟滾滾衝刺！撞開雲餅橋閘吧！" if chapter_index == 2 else "嘟嘟滾滾衝刺！撞碎巧克力和夾心餅乾吧！")
	else:
		buddy.action_pose_time = 0.28
		var banana := BananaBoomerang.new()
		banana.game = self
		banana.direction = buddy.facing
		banana.start_position = buddy.global_position + Vector2(buddy.facing * 26.0, -8.0)
		banana.position = banana.start_position
		add_child(banana)
		show_toast("香蕉迴旋鏢出發！")


func _touch_attack() -> void:
	perform_attack(get_active_buddy())


func _touch_special() -> void:
	if run_over or is_instance_valid(pause_overlay):
		return
	var active = get_active_buddy()
	if active_is_dudu():
		active.start_ground_pound()
	else:
		detect_clues()


func _touch_r_action() -> void:
	if run_over or is_instance_valid(pause_overlay):
		return
	if active_is_dudu():
		open_guide()
	else:
		drop_banana_peel(get_active_buddy())


func open_guide() -> void:
	if run_over or is_instance_valid(pause_overlay):
		return
	_clear_touch_input()
	get_tree().paused = true
	var controls := "A 跳躍；B 嘟嘟滾滾／帕恰狗香蕉迴旋鏢；X 嘟嘟屁屁坐擊／帕恰狗偵探嗅嗅；Y 集合抱抱；L 切換角色。R 是嘟嘟攻略、帕恰狗香蕉皮。"
	var chapter_guide := "第一章：先嗅出巧克力牆腳印，再讓嘟嘟滾撞；果醬河由帕恰狗踩踏板、嘟嘟撞開橋頭；Boss 踩香蕉皮滑倒後再坐擊核心。" if chapter_index == 1 else "第二章：用迴旋鏢敲響風車鈴開雲門；帕恰狗踩住雲朵踏板，嘟嘟滾破橋閘；Boss 露出鈴心後再坐擊。"
	pause_overlay = _create_overlay("攻略說明", controls + "\n\n" + chapter_guide, [["繼續遊玩", resume_game]], false)


func detect_clues() -> void:
	if active_is_dudu():
		show_toast("切換帕恰狗，按 X／E 偵探嗅嗅找線索！")
		return
	if chapter_index == 2:
		if absf(pochacco.global_position.x - cloud_windmill_x) <= 440.0:
			clues_visible = true
			clue_time = 9.0
			show_toast("帕恰狗嗅到風鈴的氣味！用香蕉迴旋鏢敲響風車，雲門就會打開。")
		else:
			show_toast("帕恰狗貼地嗅嗅……風鈴線索就在前方的雲朵風車附近。")
		queue_redraw()
		return
	if absf(pochacco.global_position.x - 1560.0) <= 390.0:
		clues_visible = true
		clue_time = 9.0
		show_toast("帕恰狗聞到了！巧克力牆後有手繪腳印和密道！")
	else:
		show_toast("帕恰狗貼地嗅嗅……目前附近沒有隱藏線索。")
	queue_redraw()


func break_barrier(block: Node) -> void:
	if not is_instance_valid(block):
		return
	if block.is_in_group("hidden_wall") and not clues_visible:
		show_toast("先切換帕恰狗按 X／E 偵探嗅嗅，找出牆上的腳印！")
		return
	if block.is_in_group("team_gate") and not team_weight_activated:
		show_toast("這個大福機關要兩個夥伴一起壓！嘟嘟站上按鈕後按 Y／F。")
		return
	if block.is_in_group("bridge_cookie") and not plate_is_held():
		show_toast("帕恰狗必須踩住雲朵踏板，浮雲橋才會降下！" if chapter_index == 2 else "帕恰狗必須踩住果醬河控制踏板，橋才會降下！")
		return
	if block.is_in_group("cloud_gate") and not cloud_windmill_active:
		show_toast("先讓帕恰狗用香蕉迴旋鏢敲響雲朵風車！")
		return
	var burst_at: Vector2 = block.global_position
	if block.is_in_group("hidden_wall"):
		clues_visible = false
		show_toast("隱藏牆碎成星星糖！密道打開了。")
	elif block.is_in_group("bridge_cookie"):
		show_toast("雲餅橋閘 Q 彈散開！通往風靈的路打通了。" if chapter_index == 2 else "夾心餅乾碎開，吊橋通路打通！")
	elif block.is_in_group("cloud_gate"):
		show_toast("雲門已隨風鈴聲打開！")
	else:
		show_toast("雙重重量機關啟動！帕恰狗撲進嘟嘟懷裡！")
	spawn_burst(burst_at, Color("#f389a8"))
	block.queue_free()
	if block == team_gate:
		team_gate = null
	if block == hidden_wall:
		hidden_wall = null
	if block == bridge_cookie:
		bridge_cookie = null
	queue_redraw()


func request_gather() -> void:
	if run_over:
		return
	if chapter_index == 1 and active_is_dudu() and absf(dudu.global_position.x - 860.0) <= 100.0 and dudu.is_on_floor():
		if team_weight_activated:
			show_toast("雙重重量機關已經打開囉！")
			return
		team_weight_activated = true
		team_hug_time = 0.7
		pochacco.global_position = dudu.global_position + Vector2(-34, -14)
		pochacco.velocity = Vector2(0, -185.0)
		pochacco.squash_time = 0.45
		if is_instance_valid(team_gate):
			break_barrier(team_gate)
		else:
			show_toast("嘟嘟和帕恰狗熊抱！雙重重量壓下開關！")
		queue_redraw()
		return
	var leader = get_active_buddy()
	var partner = pochacco if active_is_dudu() else dudu
	if not is_instance_valid(leader) or not is_instance_valid(partner):
		return
	partner.global_position = leader.global_position + Vector2(-leader.facing * 34.0, -14.0)
	partner.velocity = Vector2(0, -185.0)
	partner.squash_time = 0.45
	leader.squash_time = 0.35
	team_hug_time = 0.7
	var hug_message := "集合抱抱！切回嘟嘟站上大福按鈕，再按 Y／F 啟動雙重重量。" if chapter_index == 1 and not active_is_dudu() else "嘟嘟和帕恰狗集合抱抱！"
	show_toast(hug_message)
	queue_redraw()


func on_jump(buddy: Buddy) -> void:
	if buddy.is_dudu:
		show_toast("嘟嘟跳得高高的！空中按 X／K 屁屁坐擊。")


func on_trampoline(buddy: Buddy) -> void:
	buddy.squash_time = 0.28
	show_toast("棉花糖雲朵 Q 彈起飛！藉上升氣流跳上餅乾雲收集星星糖！" if chapter_index == 2 else "戚風蛋糕 Q 彈起飛！跳上餅乾平台收集星星糖！")
	spawn_burst(buddy.global_position + Vector2(0, 22), Color("#ffda7b"))


func on_buddy_moved(_buddy: Buddy) -> void:
	if not plate_pressed and is_instance_valid(pochacco) and absf(pochacco.global_position.x - plate_x) < 58.0 and pochacco.is_on_floor():
		plate_pressed = true
		if is_instance_valid(bridge_platform):
			bridge_platform.position.y = 535.0 + bridge_platform.size.y * 0.5
			bridge_platform.queue_redraw()
		show_toast("帕恰狗踩住雲朵踏板了！切回嘟嘟，滾破雲餅橋閘。" if chapter_index == 2 else "帕恰狗踩住踏板了！切回嘟嘟，用滾滾衝刺破開夾心餅乾。")
		_update_objective()
		queue_redraw()
	if is_instance_valid(dudu) and is_instance_valid(pochacco) and dudu.roll_time > 0.0 and dudu.global_position.distance_to(pochacco.global_position) < 58.0 and team_hug_time <= 0.0:
		team_hug_time = 0.35
		dudu.squash_time = 0.24
		pochacco.squash_time = 0.24
		dudu.velocity.x = -dudu.facing * 100.0
		pochacco.velocity.x = dudu.facing * 160.0
		spawn_burst((dudu.global_position + pochacco.global_position) * 0.5, Color("#ffd779"))


func follow_gap(buddy: Buddy) -> float:
	if buddy == dudu and is_instance_valid(pochacco):
		return maxf(0.0, pochacco.global_position.x - dudu.global_position.x)
	if buddy == pochacco and is_instance_valid(dudu):
		return maxf(0.0, dudu.global_position.x - pochacco.global_position.x)
	return 0.0


func is_mousse(x: float) -> bool:
	if chapter_index == 2:
		return false
	return x >= 1160.0 and x <= 1400.0


func is_cloud_updraft(x: float) -> bool:
	return chapter_index == 2 and ((x >= 930.0 and x <= 1260.0) or (x >= 2200.0 and x <= 2460.0) or (x >= 3650.0 and x <= 3860.0))


func plate_is_held() -> bool:
	return plate_pressed and is_instance_valid(pochacco) and absf(pochacco.global_position.x - plate_x) < 115.0


func collect_star(candy: StarCandy) -> void:
	if not is_instance_valid(candy) or run_over:
		return
	star_candies += 1
	stars_label.text = _l10n("星星糖 {count}", {"count": "%02d" % star_candies})
	spawn_burst(candy.global_position, Color("#ffdc61"))
	candy.queue_free()


func collect_ingredient(ingredient: StrawberryFood) -> void:
	if not is_instance_valid(ingredient) or run_over:
		return
	strawberry_ingredients += 1
	ingredients_label.text = _l10n("食材 {count}", {"count": "%02d" % strawberry_ingredients})
	spawn_burst(ingredient.global_position, Color("#e85d72"))
	show_toast("棉花糖食材加入小雞背包！" if chapter_index == 2 else "草莓食材加入小雞背包！")
	ingredient.queue_free()


func drop_banana_peel(buddy: Buddy) -> void:
	if buddy.is_dudu:
		return
	if chapter_index == 2:
		show_toast("雲朵風靈不怕香蕉皮！用香蕉迴旋鏢敲暈牠，再切換嘟嘟坐擊鈴心。")
		return
	banana_peel_position = buddy.global_position + Vector2(buddy.facing * 58.0, 20.0)
	banana_peel_placed = true
	show_toast("帕恰狗放下香蕉皮！把奶油怪引到這裡來。")
	queue_redraw()


func check_boomerang_hit(shot: BananaBoomerang) -> void:
	if chapter_index == 2:
		if not cloud_windmill_active and shot.global_position.distance_to(Vector2(cloud_windmill_x, GROUND_Y - 120.0)) < 52.0:
			cloud_windmill_active = true
			if is_instance_valid(cloud_gate):
				spawn_burst(cloud_gate.global_position, Color("#d8f4ed"))
				cloud_gate.queue_free()
				cloud_gate = null
			spawn_burst(Vector2(cloud_windmill_x, GROUND_Y - 120.0), Color("#f6d570"))
			show_toast("雲朵風鈴響起！雲門打開，前方氣流也變得柔和了。")
			_update_objective()
		if not boss_defeated and boss_exposed_time <= 0.0 and shot.global_position.distance_to(Vector2(boss_x, GROUND_Y - 75.0)) < 62.0:
			boss_exposed_time = 4.0
			spawn_burst(Vector2(boss_x, GROUND_Y - 58.0), Color("#f6dc82"))
			show_toast("帕恰狗的迴旋鏢敲暈風靈！月光鈴心露出來了，換嘟嘟從高處坐擊！")
			_update_objective()
	for index in bubble_positions.size():
		if bubble_stun_times[index] > 0.0:
			continue
		if shot.global_position.distance_to(bubble_positions[index]) < 34.0 and not shot.hit_ids.has(index):
			shot.hit_ids.append(index)
			bubble_stun_times[index] = 3.5
			spawn_burst(bubble_positions[index], Color("#fff4d8"))
			show_toast("奶油泡被香蕉迴旋鏢打暈了！快跳上餅乾浮盤。")


func resolve_ground_pound(buddy: Buddy) -> void:
	spawn_burst(buddy.global_position + Vector2(0, 24), Color("#f08ca6"))
	if is_instance_valid(hearts_view):
		pass
	if absf(buddy.global_position.x - boss_x) < 142.0 and boss_exposed_time > 0.0 and not boss_defeated:
		boss_defeated = true
		banana_peel_placed = false
		spawn_burst(Vector2(boss_x, GROUND_Y - 52), Color("#ffd44f"))
		spawn_burst(Vector2(boss_x + 24, GROUND_Y - 38), Color("#f48aa8"))
		show_toast("屁屁坐擊敲響月光鈴心！棉花糖風靈化成彩虹星星飛走了！" if chapter_index == 2 else "屁屁坐擊命中核心！哼哼奶油怪變成星星糖飛走了！")
		if is_instance_valid(boss_gate):
			boss_gate.queue_free()
			boss_gate = null
		_update_objective()
	else:
		show_toast("粉紅震波炸開！核心露出時，再從高處坐擊奶油怪。")
	queue_redraw()


func show_toast(message: String) -> void:
	if toast_label == null:
		return
	toast_label.text = _l10n(message)
	toast_time = 2.6
	toast_label.visible = true


func _update_objective() -> void:
	if objective_label == null:
		return
	if chapter_index == 2:
		if boss_defeated:
			objective_label.text = _l10n("找到右側的月光蜂蜜鈴，平息棉花糖風暴。")
		elif boss_exposed_time > 0.0:
			objective_label.text = _l10n("風靈的鈴心露出來了！切換嘟嘟，從高處屁屁坐擊。")
		elif plate_pressed:
			objective_label.text = _l10n("帕恰狗留在雲朵踏板；切回嘟嘟滾破雲餅橋閘。")
		elif cloud_windmill_active:
			objective_label.text = _l10n("風鈴打開雲門了！穿過浮雲橋，找到雲朵踏板。")
		else:
			objective_label.text = _l10n("用帕恰狗偵探嗅嗅找出風鈴，再以香蕉鏢敲響雲朵風車。")
		return
	if boss_defeated:
		objective_label.text = _l10n("奶油怪已化成星星糖！找到右側草莓噴泉閥門。")
	elif plate_pressed:
		objective_label.text = _l10n("帕恰狗留在踏板上；嘟嘟滾破夾心餅乾，過橋找奶油怪。")
	elif clues_visible:
		objective_label.text = _l10n("照著手繪腳印：切回嘟嘟，滾滾衝刺撞開巧克力牆。")
	elif team_weight_activated:
		objective_label.text = _l10n("用帕恰狗 X／E 偵探嗅嗅，尋找巧克力牆後的腳印。")
	else:
		objective_label.text = _l10n("用嘟嘟跳上戚風蛋糕；站上大福按鈕按 Y／F 集合。")


func damage_source(message: String, source_position: Vector2) -> void:
	if damage_cooldown > 0.0 or run_over:
		return
	damage_cooldown = 1.05
	health -= 1
	hearts_view.health = health
	var active = get_active_buddy()
	if is_instance_valid(active):
		active.receive_soft_hit()
	spawn_burst(source_position, Color("#f4a3b4"))
	if health <= 0:
		health = 3
		hearts_view.health = health
		_reset_to_checkpoint()
		show_toast("眼汪汪彈回安全小路！大福生命補滿，沒有真正死亡。")
	else:
		show_toast(message)


func fall_to_safety(_buddy: Buddy) -> void:
	if damage_cooldown > 0.0 or run_over:
		return
	_damage_and_return("噗通！跌進果醬旁的棉花軟墊，回到最近安全處。", true)


func _damage_and_return(message: String, return_both: bool) -> void:
	if damage_cooldown > 0.0:
		return
	damage_cooldown = 1.25
	health -= 1
	hearts_view.health = health
	if return_both:
		_reset_to_checkpoint()
	if health <= 0:
		health = 3
		hearts_view.health = health
		_reset_to_checkpoint()
		show_toast("眼汪汪彈回安全小路！大福生命補滿。")
	else:
		show_toast(message)


func _reset_to_checkpoint() -> void:
	if is_instance_valid(dudu):
		dudu.global_position = Vector2(checkpoint_x, GROUND_Y - 28)
		dudu.velocity = Vector2.ZERO
		dudu.roll_time = 0.0
	if is_instance_valid(pochacco):
		pochacco.global_position = Vector2(checkpoint_x - 68, GROUND_Y - 28)
		pochacco.velocity = Vector2.ZERO
		pochacco.roll_time = 0.0


func spawn_burst(at: Vector2, color: Color) -> void:
	var burst := Burst.new()
	burst.position = at
	burst.color = color
	add_child(burst)


class Burst extends Node2D:
	var age := 0.0
	var color := Color.WHITE
	func _process(delta: float) -> void:
		age += delta
		queue_redraw()
		if age > 0.48:
			queue_free()
	func _draw() -> void:
		var radius := lerpf(7.0, 42.0, clampf(age / 0.48, 0.0, 1.0))
		var alpha := 1.0 - clampf(age / 0.48, 0.0, 1.0)
		for index in 8:
			var angle := TAU * float(index) / 8.0
			var point := Vector2(cos(angle), sin(angle)) * radius
			draw_circle(point, 5.0 * alpha + 1.0, Color(color, alpha))
			draw_circle(point * 0.78, 2.2, Color("#fff9e7", alpha))


func on_buddy_arrived(_buddy: Buddy) -> void:
	pass


func on_buddy_moved_checkpoint_check() -> void:
	var active = get_active_buddy()
	if chapter_index == 2:
		if active.global_position.x > 1450.0 and checkpoint_x < 1450.0:
			checkpoint_x = 1480.0
			show_toast("棉花糖林小徑檢查點已記下！")
		elif active.global_position.x > 3750.0 and checkpoint_x < 3750.0:
			checkpoint_x = 3780.0
			show_toast("雲朵橋另一端安全！前方就是風靈的高塔。")
		return
	if active.global_position.x > 1840.0 and checkpoint_x < 1840.0:
		checkpoint_x = 1860.0
		show_toast("摸到草莓蛋糕村的小路檢查點了！")
	elif active.global_position.x > 3440.0 and checkpoint_x < 3440.0:
		checkpoint_x = 3480.0
		show_toast("吊橋另一端安全！接著對付哼哼奶油怪。")


func _process(delta: float) -> void:
	if run_over or get_tree().paused:
		return
	time_alive += delta
	damage_cooldown = maxf(0.0, damage_cooldown - delta)
	boss_contact_cooldown = maxf(0.0, boss_contact_cooldown - delta)
	team_hug_time = maxf(0.0, team_hug_time - delta)
	clue_time = maxf(0.0, clue_time - delta)
	if clue_time <= 0.0:
		clues_visible = false
	var was_boss_exposed := boss_exposed_time > 0.0
	boss_exposed_time = maxf(0.0, boss_exposed_time - delta)
	if chapter_index == 2 and was_boss_exposed and boss_exposed_time <= 0.0:
		_update_objective()
	for index in bubble_stun_times.size():
		bubble_stun_times[index] = maxf(0.0, bubble_stun_times[index] - delta)
	if not boss_defeated:
		var active = get_active_buddy()
		var desired_boss_x := 4250.0 + sin(time_alive * 0.7) * 112.0
		if is_instance_valid(active) and absf(active.global_position.x - boss_x) < 360.0:
			desired_boss_x = move_toward(boss_x, active.global_position.x + 68.0, delta * 58.0)
		boss_x = clampf(desired_boss_x, 4120.0, 4380.0)
		if banana_peel_placed and absf(boss_x - banana_peel_position.x) < 54.0:
			boss_exposed_time = 3.8
			banana_peel_placed = false
			spawn_burst(Vector2(boss_x, GROUND_Y - 56), Color("#fff3c6"))
			show_toast("哼哼奶油怪踩到香蕉皮，滑倒露出核心！嘟嘟快來屁屁坐擊！")
		if boss_exposed_time <= 0.0:
			for buddy in [dudu, pochacco]:
				if is_instance_valid(buddy) and buddy.global_position.distance_to(Vector2(boss_x, GROUND_Y - 56)) < 62.0 and boss_contact_cooldown <= 0.0:
					boss_contact_cooldown = 1.4
					var contact_message := "風靈溫柔地撞來，眼汪汪彈開！" if chapter_index == 2 else "奶油怪 Q 彈撞來了，眼汪汪彈開！"
					damage_source(contact_message, buddy.global_position)
					break
		if banana_peel_placed:
			boss_x = move_toward(boss_x, banana_peel_position.x, delta * 40.0)
	for index in bubble_positions.size():
		if bubble_stun_times[index] > 0.0 or damage_cooldown > 0.0:
			continue
		for buddy in [dudu, pochacco]:
			if is_instance_valid(buddy) and buddy.global_position.distance_to(bubble_positions[index]) < 34.0:
				var bubble_message := "棉花糖小雲泡 Q 彈碰到啦，快用香蕉迴旋鏢把它輕輕打暈！" if chapter_index == 2 else "奶油泡彈了一下，快用香蕉迴旋鏢把它打暈！"
				_damage_and_return(bubble_message, true)
				break
	var active = get_active_buddy()
	if is_instance_valid(active):
		if camera != null:
			var visible_width := get_viewport_rect().size.x
			var desired_x := clampf(active.global_position.x, visible_width * 0.5, WORLD_WIDTH - visible_width * 0.5)
			var desired := Vector2(desired_x, 360.0)
			camera.global_position = camera.global_position.lerp(desired, 1.0 - exp(-delta * 6.5))
		on_buddy_moved_checkpoint_check()
		if not boss_defeated and active.global_position.x >= 4960.0:
			show_toast("月光蜂蜜鈴被風靈守著！先用帕恰狗的香蕉鏢敲暈牠，再用嘟嘟坐擊鈴心。" if chapter_index == 2 else "噴泉閥門被奶油怪守著！先讓牠踩香蕉皮，再用嘟嘟坐擊核心。")
		elif boss_defeated and active.global_position.distance_to(Vector2(5000.0, GROUND_Y - 34.0)) < 75.0:
			finish_level()
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time <= 0.0 and is_instance_valid(toast_label):
			toast_label.visible = false
	last_ui_refresh += delta
	if last_ui_refresh > 0.16:
		last_ui_refresh = 0.0
		_refresh_touch_labels()
	queue_redraw()


func _draw() -> void:
	if chapter_index == 2:
		_draw_cloud_chapter()
		return
	draw_rect(Rect2(0, -720, WORLD_WIDTH, 1500), Color("#fff0e6"), true)
	# Distant frosting hills create a soft crayon-doodle horizon.
	for index in 11:
		var x := float(index) * 520.0 - 100.0
		var hill_height := 105.0 + float((index * 37) % 80)
		var hill := PackedVector2Array([Vector2(x, GROUND_Y + 10), Vector2(x + 120, GROUND_Y - hill_height), Vector2(x + 270, GROUND_Y - hill_height * 0.74), Vector2(x + 420, GROUND_Y + 10)])
		draw_colored_polygon(hill, Color("#f9d6d1"))
		for dot in 4:
			draw_circle(Vector2(x + 70.0 + dot * 82.0, GROUND_Y - hill_height * 0.45), 7.0, Color("#efb7c2"))
	# Clouds, a warm sun, and sprinkle stars.
	draw_circle(Vector2(450, 110), 46, Color("#ffdc7c"))
	draw_circle(Vector2(435, 95), 9, Color("#fff6d4"))
	for x in [190.0, 820.0, 1330.0, 2010.0, 2920.0, 3680.0, 4680.0]:
		_draw_cloud(x, 142.0 + sin(x * 0.009) * 35.0)
	for index in 9:
		var x := 240.0 + float(index) * 560.0
		draw_line(Vector2(x, 245.0 + fmod(x, 70.0)), Vector2(x + 10.0, 238.0 + fmod(x, 70.0)), Color("#f1bd61", 0.7), 3.0, true)
		draw_circle(Vector2(x + 17.0, 248.0 + fmod(x, 70.0)), 2.5, Color("#f6a1b3"))
	# Sweet-cake cottages in the background.
	for index in 12:
		var x := 170.0 + float(index) * 425.0
		var height := 64.0 + float((index * 23) % 48)
		draw_rect(Rect2(x, GROUND_Y - height - 5.0, 118.0, height), Color("#e9b8a8"), true)
		draw_rect(Rect2(x - 7.0, GROUND_Y - height - 16.0, 132.0, 18.0), Color("#fff1dc"), true)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 8, GROUND_Y - height - 12), Vector2(x + 58, GROUND_Y - height - 58), Vector2(x + 132, GROUND_Y - height - 12)]), Color("#d87583"))
		draw_circle(Vector2(x + 60, GROUND_Y - height * 0.52), 12.0, Color("#fff4d5"))
	# Chocolate mousse slow patch, jam rivers and tiny floating-fondant waves.
	draw_rect(Rect2(1160, GROUND_Y - 8, 240, 230), Color("#8f5e56"), true)
	for mousse_wave in 7:
		draw_arc(Vector2(1180 + mousse_wave * 36.0, GROUND_Y + 6), 17.0, PI, TAU, 14, Color("#d99a84"), 3.0, true)
	for gap in [Vector2(2120, 590), Vector2(3050, 590)]:
		draw_rect(Rect2(gap.x, gap.y, 660 if gap.x < 3000 else 330, 240), Color("#ee7894"), true)
		for jam_wave in 10:
			var wave_x: float = gap.x + 20.0 + jam_wave * (55.0 if gap.x < 3000 else 30.0)
			draw_arc(Vector2(wave_x, gap.y + 8), 18.0, PI, TAU, 16, Color("#ffb6b8"), 3.0, true)
	# Chapter name and level landmarks.
	var font: Font = GAME_FONT
	if font != null:
		draw_string(font, Vector2(110, 325), _l10n("草莓蛋糕村"), HORIZONTAL_ALIGNMENT_LEFT, -1, 31, Color("#b65570"))
		draw_string(font, Vector2(805, 563), _l10n("粉紅大福按鈕"), HORIZONTAL_ALIGNMENT_CENTER, -1, 19, Color("#9a5267"))
		draw_string(font, Vector2(2940, 575), _l10n("果醬河踏板"), HORIZONTAL_ALIGNMENT_CENTER, -1, 17, Color("#7c4e56"))
		draw_string(font, Vector2(4230, 463), _l10n("哼哼奶油怪"), HORIZONTAL_ALIGNMENT_CENTER, -1, 22, Color("#8e5960"))
	# Large cooperative button and its pressed squash.
	var button_color := Color("#d96789") if team_weight_activated else Color("#ee92a8")
	draw_circle(Vector2(860, GROUND_Y - 12), 32, button_color)
	draw_circle(Vector2(860, GROUND_Y - 12), 24, Color("#fff3db"))
	draw_circle(Vector2(860, GROUND_Y - 12), 16, Color("#f1a0b1"))
	if not team_weight_activated:
		draw_colored_polygon(PackedVector2Array([Vector2(847, GROUND_Y - 39), Vector2(853, GROUND_Y - 50), Vector2(860, GROUND_Y - 39)]), Color("#8fc27d"))
	# Bridge rails and moving platform.
	draw_line(Vector2(bridge_start, 477), Vector2(bridge_start + 340, 477), Color("#ae745d"), 7.0, true)
	draw_line(Vector2(bridge_start + 16, 477), Vector2(bridge_start + 16, 535), Color("#ae745d"), 4.0, true)
	draw_line(Vector2(bridge_start + 324, 477), Vector2(bridge_start + 324, 535), Color("#ae745d"), 4.0, true)
	# Clue footprints appear only while the detective is on the scent.
	if clues_visible:
		for index in 5:
			var x := 1425.0 + index * 32.0
			var y := GROUND_Y - 22.0 - (index % 2) * 7.0
			draw_circle(Vector2(x, y), 5.5, Color("#b05b74"))
			draw_circle(Vector2(x + 6, y - 7), 3.4, Color("#d77a8d"))
		draw_colored_polygon(PackedVector2Array([Vector2(1510, 428), Vector2(1522, 456), Vector2(1514, 454), Vector2(1510, 466), Vector2(1506, 454), Vector2(1498, 456)]), Color("#ffd75f"))
		draw_string(font, Vector2(1488, 414), "！", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#a65667"))
	# Cream bubbles at the jam crossing.
	for index in bubble_positions.size():
		var bubble := bubble_positions[index]
		if bubble_stun_times[index] > 0.0:
			draw_circle(bubble, 20.0, Color("#fff0d7", 0.75))
			draw_circle(bubble + Vector2(-5, -25), 5.0, Color("#ffd85d"))
			draw_circle(bubble + Vector2(8, -30), 4.0, Color("#f18ba1"))
		else:
			draw_circle(bubble, 24.0, Color("#fff1d8"))
			draw_circle(bubble, 24.0, Color("#ca8a83"), false, 2.0, true)
			draw_circle(bubble + Vector2(-8, -5), 3.0, Color("#74545a"))
			draw_circle(bubble + Vector2(8, -5), 3.0, Color("#74545a"))
	# Boss is a harmless-looking whipped-cream puff; its strawberry heart core appears after a slip.
	if not boss_defeated:
		var boss_center := Vector2(boss_x, GROUND_Y - 54)
		var squash := Vector2(1.0, 0.78 if boss_exposed_time > 0.0 else 1.0 + sin(time_alive * 8.0) * 0.025)
		draw_set_transform(boss_center, sin(time_alive * 3.5) * 0.025, squash)
		draw_circle(Vector2.ZERO, 47.0, Color("#fff0d8"))
		draw_circle(Vector2(-25, -15), 26.0, Color("#fff0d8"))
		draw_circle(Vector2(25, -18), 24.0, Color("#fff0d8"))
		draw_circle(Vector2(-13, -4), 4.0, Color("#60444b"))
		draw_circle(Vector2(14, -4), 4.0, Color("#60444b"))
		if boss_exposed_time > 0.0:
			draw_circle(Vector2(0, 16), 19.0, Color("#e95e7d"))
			draw_circle(Vector2(-4, 9), 4.0, Color("#fff1dd"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Fountain valve is the chapter objective.
	var valve_pos := Vector2(5000, GROUND_Y - 38)
	draw_rect(Rect2(valve_pos + Vector2(-30, -56), Vector2(60, 70)), Color("#e99aa6"), true)
	draw_rect(Rect2(valve_pos + Vector2(-25, -51), Vector2(50, 57)), Color("#fff1d5"), true)
	draw_circle(valve_pos + Vector2(0, -28), 18.0, Color("#d96c83"))
	draw_circle(valve_pos + Vector2(0, -28), 8.0, Color("#ffe09a"))
	if boss_defeated:
		draw_circle(valve_pos + Vector2(35, -72), 10.0, Color("#f3c94f"))
		draw_colored_polygon(PackedVector2Array([valve_pos + Vector2(35, -87), valve_pos + Vector2(39, -77), valve_pos + Vector2(50, -76), valve_pos + Vector2(42, -69), valve_pos + Vector2(45, -58), valve_pos + Vector2(35, -64), valve_pos + Vector2(25, -58), valve_pos + Vector2(28, -69), valve_pos + Vector2(20, -76), valve_pos + Vector2(31, -77)]), Color("#ffe174"))
	if banana_peel_placed:
		var peel := banana_peel_position
		draw_arc(peel, 19.0, PI * 1.12, PI * 1.96, 12, Color("#f3ca4d"), 8.0, true)
		draw_circle(peel + Vector2(-18, 4), 3.0, Color("#805246"))
		draw_circle(peel + Vector2(18, 3), 3.0, Color("#805246"))


func _draw_cloud_chapter() -> void:
	draw_rect(Rect2(0, -720, WORLD_WIDTH, 1500), Color("#e4f4f3"), true)
	for index in 12:
		var x := float(index) * 470.0 - 90.0
		var height := 90.0 + float((index * 31) % 82)
		draw_colored_polygon(PackedVector2Array([Vector2(x, GROUND_Y + 12), Vector2(x + 135, GROUND_Y - height), Vector2(x + 280, GROUND_Y - height * 0.68), Vector2(x + 440, GROUND_Y + 12)]), Color("#c6e5d4"))
		for puff in 3:
			draw_circle(Vector2(x + 90.0 + puff * 64.0, GROUND_Y - height * 0.46), 18.0, Color("#d7eee0"))
	for index in 8:
		var cloud_x := 250.0 + float(index) * 620.0
		_draw_cloud(cloud_x, 135.0 + sin(time_alive * 0.5 + cloud_x * 0.01) * 17.0)
	# Cotton-candy tree trunks and fluffy tops mark each stretch of the forest.
	for index in 12:
		var tree_x := 180.0 + float(index) * 430.0
		var tree_height := 74.0 + float((index * 19) % 44)
		draw_rect(Rect2(tree_x + 34.0, GROUND_Y - tree_height, 18.0, tree_height), Color("#a98c83"))
		draw_circle(Vector2(tree_x + 30.0, GROUND_Y - tree_height - 12.0), 32.0, Color("#a8d4c2"))
		draw_circle(Vector2(tree_x + 61.0, GROUND_Y - tree_height - 15.0), 29.0, Color("#b7dfcd"))
		draw_circle(Vector2(tree_x + 45.0, GROUND_Y - tree_height - 35.0), 26.0, Color("#c5e7d8"))
	# Gentle updraft ribbons show where jumps float a little longer.
	for zone in [Vector2(1100, 530), Vector2(2330, 510), Vector2(3740, 520)]:
		for ribbon in 4:
			var ribbon_x: float = zone.x + sin(time_alive * 2.3 + ribbon) * 17.0 + ribbon * 11.0
			var ribbon_y: float = zone.y - fmod(time_alive * 74.0 + ribbon * 47.0, 150.0)
			draw_line(Vector2(ribbon_x, ribbon_y + 20.0), Vector2(ribbon_x - 8.0, ribbon_y - 14.0), Color("#86c8c5", 0.62), 4.0, true)
	var font: Font = GAME_FONT
	if font != null:
		draw_string(font, Vector2(100, 332), _l10n("棉花糖雲朵森林"), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#548c86"))
		draw_string(font, Vector2(cloud_windmill_x, 464), _l10n("雲朵風車風鈴"), HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color("#658d81"))
		draw_string(font, Vector2(plate_x, 576), _l10n("雲朵踏板"), HORIZONTAL_ALIGNMENT_CENTER, -1, 17, Color("#658d81"))
		draw_string(font, Vector2(cloud_boss_x, 462), _l10n("棉花糖風靈"), HORIZONTAL_ALIGNMENT_CENTER, -1, 21, Color("#658d81"))
	# Windmill bell is the first chapter-two puzzle target.
	var mill_center := Vector2(cloud_windmill_x, GROUND_Y - 124.0)
	draw_line(mill_center + Vector2(0, 23), Vector2(cloud_windmill_x, GROUND_Y - 10), Color("#a98c83"), 6.0, true)
	for blade in 4:
		var angle := TAU * float(blade) / 4.0 + time_alive * (0.8 if not cloud_windmill_active else 0.25)
		var tip := mill_center + Vector2(cos(angle), sin(angle)) * 37.0
		draw_line(mill_center, tip, Color("#e9a8bd" if blade % 2 == 0 else "#9ecfc2"), 8.0, true)
		draw_circle(tip, 5.0, Color("#fff5de"))
	draw_circle(mill_center, 10.0, Color("#f5d678"))
	if not cloud_windmill_active:
		draw_arc(Vector2(cloud_windmill_x, GROUND_Y - 26.0), 24.0, PI, TAU, 18, Color("#e8bf5d"), 5.0, true)
	# The cloud bridge dips when Pochacco holds the matching footplate.
	draw_line(Vector2(bridge_start, 476), Vector2(bridge_start + 370, 476), Color("#91bdb6"), 6.0, true)
	draw_line(Vector2(bridge_start + 18, 476), Vector2(bridge_start + 18, 535), Color("#91bdb6"), 4.0, true)
	draw_line(Vector2(bridge_start + 352, 476), Vector2(bridge_start + 352, 535), Color("#91bdb6"), 4.0, true)
	draw_circle(Vector2(plate_x, GROUND_Y - 12), 28.0, Color("#e6a7bf") if not plate_pressed else Color("#9bd3c2"))
	draw_circle(Vector2(plate_x, GROUND_Y - 12), 17.0, Color("#fff4df"))
	if clues_visible:
		for mark in 5:
			var clue_x := cloud_windmill_x - 145.0 + mark * 30.0
			draw_circle(Vector2(clue_x, GROUND_Y - 20.0 - (mark % 2) * 7.0), 5.2, Color("#82b8a6"))
			draw_circle(Vector2(clue_x + 5.0, GROUND_Y - 27.0 - (mark % 2) * 7.0), 3.2, Color("#d98ca4"))
		draw_string(font, Vector2(cloud_windmill_x - 22, GROUND_Y - 170), "！", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("#b65d77"))
	# Small puff wisps can be gently stunned with the returning banana.
	for index in bubble_positions.size():
		var puff := bubble_positions[index]
		var squashed := bubble_stun_times[index] > 0.0
		draw_circle(puff, 21.0 if not squashed else 17.0, Color("#f5fff8"))
		draw_circle(puff + Vector2(-14, 4), 13.0, Color("#f5fff8"))
		draw_circle(puff + Vector2(14, 4), 13.0, Color("#f5fff8"))
		if not squashed:
			draw_circle(puff + Vector2(-6, -2), 2.7, Color("#657b78"))
			draw_circle(puff + Vector2(6, -2), 2.7, Color("#657b78"))
		else:
			draw_circle(puff + Vector2(0, -23), 4.0, Color("#f4d36f"))
	# Soft wind spirit; its golden bell core appears for a limited window after a hit.
	if not boss_defeated:
		var spirit_center := Vector2(boss_x, GROUND_Y - 56.0)
		var spirit_squash := Vector2(1.0, 0.8 if boss_exposed_time > 0.0 else 1.0 + sin(time_alive * 8.0) * 0.025)
		draw_set_transform(spirit_center, sin(time_alive * 3.2) * 0.025, spirit_squash)
		draw_circle(Vector2.ZERO, 45.0, Color("#d7eef0"))
		draw_circle(Vector2(-24, -14), 26.0, Color("#effaf2"))
		draw_circle(Vector2(24, -18), 24.0, Color("#effaf2"))
		draw_circle(Vector2(-12, -4), 3.5, Color("#536b6b"))
		draw_circle(Vector2(13, -4), 3.5, Color("#536b6b"))
		if boss_exposed_time > 0.0:
			draw_circle(Vector2(0, 15), 18.0, Color("#f2d26e"))
			draw_line(Vector2(-9, 15), Vector2(9, 15), Color("#a87948"), 3.0, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# The moon-honey bell marks the second chapter exit.
	var bell_pos := Vector2(5000.0, GROUND_Y - 62.0)
	draw_arc(bell_pos, 25.0, PI, TAU, 24, Color("#d8a84e"), 6.0, true)
	draw_line(bell_pos + Vector2(-22, 0), bell_pos + Vector2(22, 0), Color("#d8a84e"), 5.0, true)
	draw_circle(bell_pos + Vector2(0, -31), 8.0, Color("#f2d274"))
	if boss_defeated:
		draw_circle(bell_pos + Vector2(34, -53), 9.0, Color("#fff0a5"))
		for sparkle in 5:
			var angle := TAU * float(sparkle) / 5.0 + time_alive
			draw_circle(bell_pos + Vector2(cos(angle), sin(angle)) * 37.0, 3.0, Color("#fff5c8"))


func _draw_cloud(x: float, y: float) -> void:
	draw_circle(Vector2(x, y), 25.0, Color("#fff9ef", 0.86))
	draw_circle(Vector2(x + 28, y - 9), 33.0, Color("#fff9ef", 0.9))
	draw_circle(Vector2(x + 62, y), 25.0, Color("#fff9ef", 0.86))
	draw_rect(Rect2(x - 2, y - 1, 65, 25), Color("#fff9ef", 0.88), true)


func is_active_dudu() -> bool:
	return active_is_dudu()


func _touch_action(action_name: String) -> void:
	if action_name == "switch":
		switch_character()


func open_pause() -> void:
	if run_over or is_instance_valid(pause_overlay):
		return
	_clear_touch_input()
	get_tree().paused = true
	var pause_message := "棉花糖雲朵森林的旅程會在這裡等你。" if chapter_index == 2 else "草莓蛋糕村的旅程會在這裡等你。"
	pause_overlay = _create_overlay("先休息一下", pause_message, [["繼續遊玩", resume_game], ["重新開始", restart_game], ["回到首頁", return_to_title]], false)


func resume_game() -> void:
	get_tree().paused = false
	if is_instance_valid(pause_overlay):
		pause_overlay.queue_free()
	pause_overlay = null


func restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func return_to_title() -> void:
	get_tree().paused = false
	get_tree().set_meta("snackisle_chapter", 1)
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func finish_level() -> void:
	if run_over:
		return
	run_over = true
	if is_instance_valid(dudu):
		dudu.victory_pose = true
	if is_instance_valid(pochacco):
		pochacco.victory_pose = true
	_clear_touch_input()
	if chapter_index == 2:
		var cloud_result := _l10n("月光蜂蜜鈴重新響起，棉花糖風暴平息了。\n\n星星糖：{count} 顆\n嘟嘟和帕恰狗完成了雲朵森林冒險！", {"count": "%02d" % star_candies})
		result_overlay = _create_overlay("月光蜂蜜鈴找回來了！", cloud_result, [["再玩第二章", restart_game], ["回到首頁", return_to_title]], true)
	else:
		var result_text := _l10n("草莓噴泉回復平靜，怪盜喵嗚的果醬大計泡湯啦。\n\n星星糖：{count} 顆\n嘟嘟和帕恰狗完成了草莓蛋糕村野餐！", {"count": "%02d" % star_candies})
		result_overlay = _create_overlay("閥門找回來了！", result_text, [["前往第二章", start_chapter_two], ["再玩第一章", restart_game], ["回到首頁", return_to_title]], true)


func start_chapter_two() -> void:
	get_tree().paused = false
	get_tree().set_meta("snackisle_chapter", 2)
	get_tree().reload_current_scene()


func _create_overlay(heading: String, body_text: String, actions: Array, terminal: bool) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.layer = 40
	add_child(layer)
	var blocker := ColorRect.new()
	blocker.color = Color(0.28, 0.12, 0.17, 0.38 if not terminal else 0.58)
	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(blocker)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(minf(480.0, get_viewport_rect().size.x - 32.0), 0)
	_style_panel(panel, Color("#fff8ea"), Color("#d98999"))
	center.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 11)
	panel.add_child(stack)
	var title := Label.new()
	title.text = _l10n(heading)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 31)
	title.add_theme_color_override("font_color", Color("#b54f6c"))
	stack.add_child(title)
	var body := Label.new()
	body.text = _l10n(body_text)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 18)
	body.add_theme_color_override("font_color", Color("#694c52"))
	stack.add_child(body)
	for index in actions.size():
		var action: Array = actions[index]
		var button := _make_button(_l10n(action[0]), 0, 52, terminal and index == 0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(action[1])
		stack.add_child(button)
	return layer


func _update_objective_after_clue() -> void:
	_update_objective()
