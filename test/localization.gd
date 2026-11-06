extends SceneTree

const FONT: Font = preload("res://assets/template/fonts/ui_regular.tres")
const REQUIRED_COPY := [
	"嘟嘟與帕恰狗\n點心島的奇幻野餐",
	"第一章｜草莓蛋糕村",
	"怪盜喵嗚偷走了草莓噴泉閥門，果醬快要淹到村子了。切換兩位夥伴、解開合作機關，找回閥門！",
	"開始冒險",
	"切換\n角色",
	"偵探\n嗅嗅",
		"屁屁\n坐擊",
		"香蕉\n迴旋",
		"星星糖 {count}",
		"小雞背包",
		"食材 {count}",
		"現在由{name}帶隊！",
		"哼哼奶油怪",
]
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for _frame in 3:
		await process_frame
	var i18n := root.get_node_or_null("I18n")
	_check(i18n != null, "I18n autoload exists")
	if i18n == null:
		_finish()
		return
	_check(i18n.get_locale() == "zh-TW", "fresh game locale is fixed to Traditional Chinese")
	_check(i18n.SUPPORTED_LOCALES == ["zh-TW"], "only the requested zh-TW catalog is exposed")
	_check(not i18n.set_locale("en") and i18n.get_locale() == "zh-TW", "unsupported locale cannot switch the game")
	_check(i18n.locale_for_system("en_US") == "zh-TW" and i18n.locale_for_system("zh-CN") == "zh-TW", "browser or OS language never auto-switches the game")
	var catalog: Dictionary = i18n.catalog("zh-TW")
	_check(not catalog.is_empty(), "Traditional Chinese copy catalog is loaded")
	for copy: String in REQUIRED_COPY:
			_check(catalog.has(copy), "catalog includes required live text: " + copy)
			_check(i18n.t(copy) == copy, "catalog resolves required text: " + copy)
	for key: String in ["短版故事", "短版控制", "短版PWA"]:
		_check(catalog.has(key) and i18n.t(key) == str(catalog.get(key, "")), "catalog resolves compact title copy: " + key)
	for key: String in catalog:
		var value := str(catalog[key])
		var token_pattern := RegEx.create_from_string("\\{([a-z_]+)\\}")
		var keys: Array[String] = []
		for token: RegExMatch in token_pattern.search_all(key):
			keys.append(token.get_string(1))
		keys.sort()
		var values: Array[String] = []
		for token: RegExMatch in token_pattern.search_all(value):
			values.append(token.get_string(1))
		values.sort()
		_check(keys == values, "whole-message placeholder parity: " + key)
	for character: String in "繁體中文嘟嘟帕恰狗點心島莓噴泉閥門果醬":
		_check(FONT.has_char(character.unicode_at(0)), "bundled font chain covers: " + character)
	_check(FONT.fallbacks.size() >= 2, "font chain contains TC and SC fallback faces")
	if FONT.fallbacks.size() >= 2:
		_check(FONT.fallbacks[0].get_font_name().begins_with("Noto Sans TC"), "Noto Sans TC precedes Simplified Chinese fallback")
		_check(FONT.fallbacks[1].get_font_name().begins_with("Noto Sans SC"), "Noto Sans SC remains a later fallback")
	var title_scene: PackedScene = load("res://scenes/title_screen.tscn") as PackedScene
	var title: Control = title_scene.instantiate()
	root.add_child(title)
	for _frame in 3:
		await process_frame
	var title_label: Label = title.find_child("GameTitle", true, false)
	var start_button: Button = title.find_child("StartAdventure", true, false)
	_check(title_label != null and title_label.text == "嘟嘟與帕恰狗\n點心島的奇幻野餐", "title renders Traditional Chinese through the service")
	_check(start_button != null and start_button.text == "開始冒險", "start control is Traditional Chinese")
	title.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for message in failures:
		push_error("[SNACKISLE_LOCALIZATION_FAIL] " + message)
	if failures.is_empty():
		print("[SNACKISLE_LOCALIZATION_PASS] pinned zh-TW, live catalog, placeholders, TC-before-SC font fallback and title UI")
	quit(0 if failures.is_empty() else 1)
