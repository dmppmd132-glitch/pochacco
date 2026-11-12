extends "res://scripts/menu_modal.gd"

const CATALOG := preload("res://scripts/costume_catalog.gd")

## Demo-only balance for the standalone scene. The real balance will be injected
## from SaveStore when persistence is implemented.
@export_range(0, 9999, 1) var preview_star_balance := 18

signal unlock_requested(costume_id: String, price: int)
signal equip_requested(costume_id: String)

var _star_balance := 0
var _unlocked_ids: Array[String] = []
var _equipped_by_character: Dictionary = {}
var _active_character_id := "dudu"
var _selected_costume_id := ""
var _character_buttons: Dictionary = {}

var _balance_label: Label
var _costume_list: VBoxContainer
var _preview_texture: TextureRect
var _preview_art_hint: Label
var _preview_name: Label
var _preview_description: Label
var _status_label: Label
var _action_button: Button
var _request_hint: Label


func _ready() -> void:
	super._ready()
	_star_balance = preview_star_balance
	_unlocked_ids = CATALOG.default_unlocked_ids()
	_equipped_by_character = CATALOG.default_equipment()
	_build_wardrobe_ui()
	_select_character(_active_character_id)
	call_deferred("open_panel")


## Integration entry point for a future title-screen caller. This is a read-only
## snapshot; this draft never mutates or saves currency/inventory itself.
func set_preview_snapshot(star_balance: int, unlocked_ids: Array, equipped_by_character: Dictionary) -> void:
	_star_balance = clampi(star_balance, 0, int(CATALOG.currency().get("wallet_cap", 9999)))
	_unlocked_ids.clear()
	for value: Variant in unlocked_ids:
		if value is String and not _unlocked_ids.has(value):
			_unlocked_ids.append(value)
	_equipped_by_character = equipped_by_character.duplicate(true)
	if _balance_label != null:
		_refresh_view()


func _build_wardrobe_ui() -> void:
	content.add_theme_constant_override("separation", 12)
	content.add_child(STYLE.ribbon("星星糖衣櫃", 34))

	_balance_label = STYLE.label("", 18)
	_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_balance_label)

	var tabs := HBoxContainer.new()
	tabs.name = "CharacterTabs"
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 8)
	content.add_child(tabs)
	var tab_group := ButtonGroup.new()
	for character: Dictionary in CATALOG.characters():
		var character_id := str(character.get("id", ""))
		var button := STYLE.button(str(character.get("display_name", character_id)))
		button.name = "Character_%s" % character_id
		button.toggle_mode = true
		button.button_group = tab_group
		button.custom_minimum_size = Vector2(130, 48)
		button.pressed.connect(_select_character.bind(character_id))
		tabs.add_child(button)
		_character_buttons[character_id] = button

	var preview_card := PanelContainer.new()
	STYLE.felt_card(preview_card, Color("#fff0d1"), 14)
	content.add_child(preview_card)
	var preview_row := HBoxContainer.new()
	preview_row.add_theme_constant_override("separation", 14)
	preview_card.add_child(preview_row)
	_preview_texture = TextureRect.new()
	_preview_texture.name = "CostumePreview"
	_preview_texture.custom_minimum_size = Vector2(104, 104)
	_preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_row.add_child(_preview_texture)
	var preview_text := VBoxContainer.new()
	preview_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_text.add_theme_constant_override("separation", 4)
	preview_row.add_child(preview_text)
	_preview_name = STYLE.label("", 21)
	_preview_name.add_theme_color_override("font_color", STYLE.COCOA)
	preview_text.add_child(_preview_name)
	_preview_description = STYLE.label("", 15)
	_preview_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_description.add_theme_color_override("font_color", STYLE.MUTED)
	preview_text.add_child(_preview_description)
	_preview_art_hint = STYLE.label("", 13)
	_preview_art_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_art_hint.add_theme_color_override("font_color", STYLE.MUTED)
	preview_text.add_child(_preview_art_hint)

	_status_label = STYLE.label("", 16)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_status_label)

	var list_heading := STYLE.label("服裝目錄", 17)
	list_heading.add_theme_color_override("font_color", STYLE.COCOA)
	content.add_child(list_heading)
	_costume_list = VBoxContainer.new()
	_costume_list.name = "CostumeList"
	_costume_list.add_theme_constant_override("separation", 6)
	content.add_child(_costume_list)

	_action_button = STYLE.button("", true)
	_action_button.custom_minimum_size.y = 50
	_action_button.pressed.connect(_on_action_pressed)
	content.add_child(_action_button)
	_request_hint = STYLE.label("此為 UI 草稿；按鈕只送出訊號，尚未連接 SaveStore，不會實際扣糖或存檔。", 13)
	_request_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_request_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_request_hint.add_theme_color_override("font_color", STYLE.MUTED)
	content.add_child(_request_hint)
	add_close_button()


func _select_character(character_id: String) -> void:
	if CATALOG.all_costumes(character_id).is_empty():
		return
	_active_character_id = character_id
	_selected_costume_id = ""
	for key: String in _character_buttons:
		var button: Button = _character_buttons[key]
		button.set_pressed_no_signal(key == character_id)
	_refresh_view()


func _select_costume(costume_id: String) -> void:
	_selected_costume_id = costume_id
	_refresh_view()


func _refresh_view() -> void:
	if _balance_label == null:
		return
	_balance_label.text = "示意星星糖餘額：%d 顆" % _star_balance
	var entries := CATALOG.all_costumes(_active_character_id)
	if entries.is_empty():
		return
	var selected := CATALOG.get_costume(_selected_costume_id)
	if selected.is_empty() or str(selected.get("character_id", "")) != _active_character_id:
		_selected_costume_id = str(entries[0].get("id", ""))
	_rebuild_costume_list(entries)
	_refresh_preview(CATALOG.get_costume(_selected_costume_id))


func _rebuild_costume_list(entries: Array[Dictionary]) -> void:
	for child: Node in _costume_list.get_children():
		_costume_list.remove_child(child)
		child.queue_free()
	for item: Dictionary in entries:
		var costume_id := str(item.get("id", ""))
		var name := str(item.get("display_name", costume_id))
		var price := int(item.get("price", 0))
		var state := "已穿戴" if CATALOG.is_equipped(costume_id, _equipped_by_character) else ("已解鎖" if CATALOG.is_unlocked(costume_id, _unlocked_ids) else "%d 顆星星糖" % price)
		var button := STYLE.button("%s　｜　%s" % [name, state])
		button.name = "Costume_%s" % costume_id
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 46
		button.pressed.connect(_select_costume.bind(costume_id))
		_costume_list.add_child(button)


func _refresh_preview(item: Dictionary) -> void:
	if item.is_empty():
		return
	var costume_id := str(item.get("id", ""))
	var name := str(item.get("display_name", costume_id))
	var character_id := str(item.get("character_id", ""))
	var character_name := character_id
	for character: Dictionary in CATALOG.characters():
		if str(character.get("id", "")) == character_id:
			character_name = str(character.get("display_name", character_id))
			break
	_preview_name.text = name
	_preview_description.text = str(item.get("description", ""))
	var preview_path := str(item.get("preview_texture_path", ""))
	if not preview_path.is_empty() and ResourceLoader.exists(preview_path):
		_preview_texture.texture = load(preview_path) as Texture2D
		_preview_art_hint.text = "外觀預覽：%s" % character_name if str(item.get("asset_status", "")) == "existing_portrait_preview" else ""
	else:
		_preview_texture.texture = null
		_preview_art_hint.text = "外觀素材尚待製作；目前顯示服裝資料與解鎖狀態。"

	var unlocked := CATALOG.is_unlocked(costume_id, _unlocked_ids)
	var equipped := CATALOG.is_equipped(costume_id, _equipped_by_character)
	var price := int(item.get("price", 0))
	if equipped:
		_status_label.text = "目前穿戴中"
		_action_button.text = "目前穿戴"
		_action_button.disabled = true
	elif unlocked:
		_status_label.text = "已解鎖，可穿戴"
		_action_button.text = "穿戴"
		_action_button.disabled = false
	elif CATALOG.can_unlock(costume_id, _star_balance, _unlocked_ids):
		_status_label.text = "可用 %d 顆星星糖解鎖；確認後才會扣除。" % price
		_action_button.text = "解鎖（%d 顆）" % price
		_action_button.disabled = false
	else:
		_status_label.text = "星星糖不足，還差 %d 顆。" % maxi(0, price - _star_balance)
		_action_button.text = "星星糖不足"
		_action_button.disabled = true


func _on_action_pressed() -> void:
	var item := CATALOG.get_costume(_selected_costume_id)
	if item.is_empty():
		return
	if CATALOG.is_unlocked(_selected_costume_id, _unlocked_ids):
		if CATALOG.is_equipped(_selected_costume_id, _equipped_by_character):
			return
		equip_requested.emit(_selected_costume_id)
		_request_hint.text = "已送出穿戴請求；正式流程由外部更新存檔快照後再刷新介面。"
		return
	if CATALOG.can_unlock(_selected_costume_id, _star_balance, _unlocked_ids):
		unlock_requested.emit(_selected_costume_id, int(item.get("price", 0)))
		_request_hint.text = "已送出解鎖請求；正式流程需先確認，再由 SaveStore 原子扣糖。"
