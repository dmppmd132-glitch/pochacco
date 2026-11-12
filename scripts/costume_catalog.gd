class_name CostumeCatalog
extends RefCounted

## Data-only catalog and pure unlock predicates. Persistence and purchases belong
## to SaveStore in the next implementation stage.
const CATALOG_PATH := "res://data/costumes/catalog.json"

static var _load_attempted := false
static var _cached_catalog: Dictionary = {}


static func characters() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw: Variant in _read_catalog().get("characters", []):
		if raw is Dictionary:
			result.append(raw.duplicate(true))
	return result


static func all_costumes(character_id: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw: Variant in _read_catalog().get("costumes", []):
		if not raw is Dictionary:
			continue
		if character_id.is_empty() or str(raw.get("character_id", "")) == character_id:
			result.append(raw.duplicate(true))
	return result


static func get_costume(costume_id: String) -> Dictionary:
	for item: Dictionary in all_costumes():
		if str(item.get("id", "")) == costume_id:
			return item
	return {}


static func currency() -> Dictionary:
	var value: Variant = _read_catalog().get("currency", {})
	return value.duplicate(true) if value is Dictionary else {}


static func default_unlocked_ids() -> Array[String]:
	var result: Array[String] = []
	for item: Dictionary in all_costumes():
		if bool(item.get("unlocked_by_default", false)):
			result.append(str(item.get("id", "")))
	return result


static func default_equipment() -> Dictionary:
	var result: Dictionary = {}
	for character: Dictionary in characters():
		var character_id := str(character.get("id", ""))
		var slots: Dictionary = {}
		var outfit_id := str(character.get("default_outfit_id", ""))
		if not outfit_id.is_empty():
			slots["outfit"] = outfit_id
		var headwear_id := str(character.get("default_headwear_id", ""))
		if not headwear_id.is_empty():
			slots["headwear"] = headwear_id
		result[character_id] = slots
	return result


static func is_unlocked(costume_id: String, unlocked_ids: Array = []) -> bool:
	var item := get_costume(costume_id)
	return not item.is_empty() and (bool(item.get("unlocked_by_default", false)) or unlocked_ids.has(costume_id))


static func is_equipped(costume_id: String, equipped_by_character: Dictionary) -> bool:
	var item := get_costume(costume_id)
	if item.is_empty():
		return false
	var character_state: Variant = equipped_by_character.get(str(item.get("character_id", "")), {})
	if not character_state is Dictionary:
		return false
	return str(character_state.get(str(item.get("slot", "")), "")) == costume_id


static func can_unlock(costume_id: String, star_balance: int, unlocked_ids: Array = []) -> bool:
	var item := get_costume(costume_id)
	if item.is_empty() or is_unlocked(costume_id, unlocked_ids):
		return false
	var currency_data := currency()
	if str(item.get("unlock_currency_id", "")) != str(currency_data.get("id", "")):
		return false
	var price_value: Variant = item.get("price", 0)
	if not _is_non_negative_integer(price_value) or int(price_value) <= 0:
		return false
	var wallet_cap := int(currency_data.get("wallet_cap", 9999))
	return star_balance >= int(price_value) and star_balance <= wallet_cap


static func _is_non_negative_integer(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return int(value) >= 0
	if typeof(value) != TYPE_FLOAT:
		return false
	var number := float(value)
	return is_finite(number) and number >= 0.0 and number <= 2147483647.0 and is_equal_approx(number, roundf(number))


static func validate_current_catalog() -> PackedStringArray:
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		return PackedStringArray(["catalog file cannot be opened"])
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return PackedStringArray(["catalog root must be a JSON object"])
	return validate_catalog(parsed)


static func validate_catalog(value: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	if int(value.get("schema_version", 0)) != 1:
		errors.append("schema_version must be 1")
	var currency_value: Variant = value.get("currency", {})
	if not currency_value is Dictionary or str(currency_value.get("id", "")) != "star_candy":
		errors.append("currency.id must be star_candy")
	var characters_value: Variant = value.get("characters", [])
	var costumes_value: Variant = value.get("costumes", [])
	if not characters_value is Array:
		errors.append("characters must be an array")
		return errors
	if not costumes_value is Array:
		errors.append("costumes must be an array")
		return errors

	var character_ids: Dictionary = {}
	for raw_character: Variant in characters_value:
		if not raw_character is Dictionary:
			errors.append("each character must be an object")
			continue
		var character_id := str(raw_character.get("id", ""))
		if character_id.is_empty() or character_ids.has(character_id):
			errors.append("character IDs must be non-empty and unique")
		else:
			character_ids[character_id] = raw_character

	var costume_ids: Dictionary = {}
	for raw_costume: Variant in costumes_value:
		if not raw_costume is Dictionary:
			errors.append("each costume must be an object")
			continue
		var costume_id := str(raw_costume.get("id", ""))
		if costume_id.is_empty() or costume_ids.has(costume_id):
			errors.append("costume IDs must be non-empty and unique")
			continue
		costume_ids[costume_id] = raw_costume
		if not character_ids.has(str(raw_costume.get("character_id", ""))):
			errors.append("%s references an unknown character" % costume_id)
		if str(raw_costume.get("slot", "")) not in ["outfit", "headwear"]:
			errors.append("%s has an unsupported slot" % costume_id)
		if not raw_costume.get("display_name", "") is String:
			errors.append("%s needs a display_name" % costume_id)
		var price_value: Variant = raw_costume.get("price", -1)
		if not _is_non_negative_integer(price_value):
			errors.append("%s needs a non-negative integer price" % costume_id)
		elif bool(raw_costume.get("unlocked_by_default", false)) and int(price_value) != 0:
			errors.append("%s is default-unlocked and must cost 0" % costume_id)
		elif not bool(raw_costume.get("unlocked_by_default", false)) and (int(price_value) <= 0 or str(raw_costume.get("unlock_currency_id", "")) != "star_candy"):
			errors.append("%s must use a positive star_candy price" % costume_id)

	for character_id: String in character_ids:
		var character: Dictionary = character_ids[character_id]
		for field in ["default_outfit_id", "default_headwear_id"]:
			var default_id := str(character.get(field, ""))
			if default_id.is_empty():
				continue
			if not costume_ids.has(default_id):
				errors.append("%s references missing %s" % [character_id, field])
				continue
			var default_costume: Dictionary = costume_ids[default_id]
			if str(default_costume.get("character_id", "")) != character_id or not bool(default_costume.get("unlocked_by_default", false)):
				errors.append("%s must reference an unlocked costume for the same character" % field)
	return errors


static func _read_catalog() -> Dictionary:
	if _load_attempted:
		return _cached_catalog
	_load_attempted = true
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_error("CostumeCatalog could not open %s" % CATALOG_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("CostumeCatalog root must be a JSON object")
		return {}
	var errors := validate_catalog(parsed)
	if not errors.is_empty():
		push_error("Invalid costume catalog: " + "; ".join(errors))
		return {}
	_cached_catalog = parsed
	return _cached_catalog
