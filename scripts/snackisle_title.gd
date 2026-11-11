extends Control

const DUDU_TEXTURE: Texture2D = preload("res://assets/snackisle/dudu-512.png")
const POCHACCO_TEXTURE: Texture2D = preload("res://assets/snackisle/pochacco-512.png")
const TITLE_FONT: Font = preload("res://assets/template/fonts/display/display_title.tres")

var title_panel: PanelContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_title()
	get_viewport().size_changed.connect(_layout_title)
	queue_redraw()


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("#fff2e8"), true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, viewport_size.y * 0.73),
		Vector2(viewport_size.x * 0.18, viewport_size.y * 0.61),
		Vector2(viewport_size.x * 0.39, viewport_size.y * 0.74),
		Vector2(viewport_size.x * 0.63, viewport_size.y * 0.58),
		Vector2(viewport_size.x, viewport_size.y * 0.7),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0, viewport_size.y),
	]), Color("#f7d7d5"))
	for index in 6:
		var x := viewport_size.x * (0.1 + index * 0.16)
		var y := viewport_size.y * (0.15 + fmod(index * 0.13, 0.3))
		draw_circle(Vector2(x, y), 17.0 + float(index % 3) * 6.0, Color("#fffaf1", 0.7))
		draw_circle(Vector2(x + 20, y - 4), 19.0, Color("#fffaf1", 0.7))
		draw_circle(Vector2(x + 38, y), 14.0, Color("#fffaf1", 0.7))
	for index in 18:
		var x := fmod(float(index) * 83.0 + 22.0, maxf(1.0, viewport_size.x))
		var y := fmod(float(index) * 47.0 + 25.0, maxf(1.0, viewport_size.y * 0.52))
		draw_circle(Vector2(x, y), 2.7, Color("#e7a0ae", 0.7))


func _build_title() -> void:
	var center := CenterContainer.new()
	center.name = "TitleCenter"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	title_panel = PanelContainer.new()
	title_panel.name = "DiaryCard"
	title_panel.custom_minimum_size = Vector2(520, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#fffaf0")
	panel_style.border_color = Color("#d89991")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(28)
	panel_style.content_margin_left = 22
	panel_style.content_margin_right = 22
	panel_style.content_margin_top = 16
	panel_style.content_margin_bottom = 16
	panel_style.shadow_color = Color(0.34, 0.16, 0.2, 0.16)
	panel_style.shadow_size = 8
	panel_style.shadow_offset = Vector2(0, 5)
	title_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(title_panel)
	var stack := VBoxContainer.new()
	stack.name = "TitleContent"
	stack.add_theme_constant_override("separation", 7)
	title_panel.add_child(stack)
	var character_row := HBoxContainer.new()
	character_row.alignment = BoxContainer.ALIGNMENT_CENTER
	character_row.add_theme_constant_override("separation", 25)
	stack.add_child(character_row)
	character_row.add_child(_character_art("嘟嘟", DUDU_TEXTURE))
	character_row.add_child(_character_art("帕恰狗", POCHACCO_TEXTURE))
	var title := Label.new()
	title.name = "GameTitle"
	title.text = _l10n("嘟嘟與帕恰狗\n點心島的奇幻野餐")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#b94f70"))
	stack.add_child(title)
	var chapter := Label.new()
	chapter.name = "GameChapter"
	chapter.text = _l10n("第一章｜草莓蛋糕村")
	chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter.add_theme_font_override("font", TITLE_FONT)
	chapter.add_theme_font_size_override("font_size", 22)
	chapter.add_theme_color_override("font_color", Color("#7d5960"))
	stack.add_child(chapter)
	var story := Label.new()
	story.name = "StoryText"
	story.text = _l10n("怪盜喵嗚偷走了草莓噴泉閥門，果醬快要淹到村子了。切換兩位夥伴、解開合作機關，找回閥門！")
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.add_theme_font_size_override("font_size", 17)
	story.add_theme_color_override("font_color", Color("#634f54"))
	stack.add_child(story)
	var controls := Label.new()
	controls.name = "ControlsHint"
	controls.text = _l10n("←→／A D 移動　Space／↑ 跳躍　L／Tab 切換\n觸控／手把：A 跳躍　B 滾動／迴旋　X 坐擊／嗅嗅　Y 抱抱\n肩鍵 L 切換；R 嘟嘟看攻略／帕恰狗放香蕉皮\n鍵盤快捷：J／X 攻擊、K 坐擊、E 嗅嗅、F 抱抱、R 攻略／香蕉皮、C 香蕉皮")
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 15)
	controls.add_theme_color_override("font_color", Color("#765c61"))
	stack.add_child(controls)
	var install_hint := Label.new()
	install_hint.name = "InstallHint"
	install_hint.text = _l10n("PWA 安裝：使用瀏覽器選單的「安裝應用程式／加入主畫面」。首次完整載入後可離線遊玩。")
	install_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	install_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	install_hint.add_theme_font_size_override("font_size", 13)
	install_hint.add_theme_color_override("font_color", Color("#91777a"))
	stack.add_child(install_hint)
	var start_button := _make_button("開始冒險", true)
	start_button.name = "StartAdventure"
	start_button.pressed.connect(_start_game)
	stack.add_child(start_button)
	var chapter_two_button := _make_button("體驗第二章｜雲朵森林", false)
	chapter_two_button.name = "StartChapterTwo"
	chapter_two_button.pressed.connect(_start_chapter_two)
	stack.add_child(chapter_two_button)
	var footer := Label.new()
	footer.name = "FooterHint"
	footer.text = _l10n("粉紅大福 × 香蕉上衣 × 星星糖")
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color("#c08082"))
	stack.add_child(footer)
	_layout_title()


func _character_art(label_text: String, texture: Texture2D) -> Control:
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 0)
	var portrait := TextureRect.new()
	portrait.name = "CharacterPortrait"
	portrait.custom_minimum_size = Vector2(108, 94)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = texture
	column.add_child(portrait)
	var label := Label.new()
	label.text = _l10n(label_text)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("#80535c"))
	column.add_child(label)
	return column


func _make_button(label: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = _l10n(label)
	button.custom_minimum_size = Vector2(220, 54)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color("#674751"))
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#ee9dad") if primary else Color("#fff0d1")
		if state == "hover":
			style.bg_color = Color("#f4b2bc")
		elif state == "pressed":
			style.bg_color = Color("#d7778e")
		style.border_color = Color("#bf667c")
		style.set_border_width_all(2)
		style.set_corner_radius_all(18)
		button.add_theme_stylebox_override(state, style)
	return button


func _layout_title() -> void:
	if title_panel == null:
		return
	var view_size := get_viewport_rect().size
	var compact := view_size.y < 700.0
	var micro := view_size.y < 400.0
	var width := view_size.x
	title_panel.custom_minimum_size.x = minf(540.0, maxf(292.0, width - 28.0))
	var content := title_panel.find_child("TitleContent", true, false) as VBoxContainer
	if content != null:
		content.add_theme_constant_override("separation", 2 if compact else 7)
	var style := title_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style != null:
		style.content_margin_left = 14 if compact else 22
		style.content_margin_right = 14 if compact else 22
		style.content_margin_top = 4 if compact else 16
		style.content_margin_bottom = 4 if compact else 16
	var portraits := title_panel.find_children("CharacterPortrait", "TextureRect", true, false)
	for node in portraits:
		var portrait := node as TextureRect
		portrait.custom_minimum_size = Vector2(78, 42) if micro else (Vector2(86, 54) if compact else Vector2(108, 94))
	var game_title := title_panel.find_child("GameTitle", true, false) as Label
	if game_title != null:
		game_title.add_theme_font_size_override("font_size", 22 if micro else (26 if compact else 34))
	var chapter := title_panel.find_child("GameChapter", true, false) as Label
	if chapter != null:
		chapter.add_theme_font_size_override("font_size", 15 if micro else (17 if compact else 22))
	var story := title_panel.find_child("StoryText", true, false) as Label
	if story != null:
		story.text = _l10n("短版故事") if compact else _l10n("怪盜喵嗚偷走了草莓噴泉閥門，果醬快要淹到村子了。切換兩位夥伴、解開合作機關，找回閥門！")
		story.visible = not micro
		story.add_theme_font_size_override("font_size", 14 if compact else 17)
	var controls := title_panel.find_child("ControlsHint", true, false) as Label
	if controls != null:
		controls.text = _l10n("短版控制") if compact else _l10n("←→／A D 移動　Space／↑ 跳躍　L／Tab 切換\n觸控／手把：A 跳躍　B 滾動／迴旋　X 坐擊／嗅嗅　Y 抱抱\n肩鍵 L 切換；R 嘟嘟看攻略／帕恰狗放香蕉皮\n鍵盤快捷：J／X 攻擊、K 坐擊、E 嗅嗅、F 抱抱、R 攻略／香蕉皮、C 香蕉皮")
		controls.add_theme_font_size_override("font_size", 10 if compact else 15)
	var install_hint := title_panel.find_child("InstallHint", true, false) as Label
	if install_hint != null:
		install_hint.text = _l10n("短版PWA") if compact else _l10n("PWA 安裝：使用瀏覽器選單的「安裝應用程式／加入主畫面」。首次完整載入後可離線遊玩。")
		install_hint.visible = not micro
		install_hint.add_theme_font_size_override("font_size", 10 if compact else 13)
	var footer := title_panel.find_child("FooterHint", true, false) as Label
	if footer != null:
		footer.visible = not compact
		footer.add_theme_font_size_override("font_size", 13 if not compact else 11)
	var start_button := title_panel.find_child("StartAdventure", true, false) as Button
	if start_button != null:
		start_button.custom_minimum_size = Vector2(200, 42) if compact else Vector2(220, 54)
		start_button.add_theme_font_size_override("font_size", 18 if compact else 22)
	var chapter_two_button := title_panel.find_child("StartChapterTwo", true, false) as Button
	if chapter_two_button != null:
		chapter_two_button.custom_minimum_size = Vector2(200, 42) if compact else Vector2(220, 48)
		chapter_two_button.add_theme_font_size_override("font_size", 14 if compact else 17)


func _l10n(value: String, placeholders: Dictionary = {}) -> String:
	return get_node("/root/I18n").t(value, placeholders)


func _start_game() -> void:
	get_tree().set_meta("snackisle_chapter", 1)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _start_chapter_two() -> void:
	get_tree().set_meta("snackisle_chapter", 2)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
