extends SceneTree

const FAILING_SAVE_STORE := preload("res://test/failing_costume_save_store.gd")

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var store := root.get_node("SaveStore")
	var save_path: String = store.SAVE_PATH
	var original_exists := FileAccess.file_exists(save_path)
	var original_text := FileAccess.get_file_as_string(save_path) if original_exists else ""

	_check(_write_json(save_path, {
		"version": 2,
		"best_score": 4321,
		"player_name": "Player",
		"records": [],
		"tutorial_version": 1,
	}), "could not write v2 migration fixture")
	store.load_save()
	_check(store.best_score() == 4321, "v2 migration preserves existing best score")
	_check(int(store.data.get("version", 0)) == 3, "v2 data loads into the v3 schema")
	_check(store.get_star_candy_balance() == 0, "v2 migration starts with a zero star-candy balance")
	_check(store.get_unlocked_costume_ids().has("dudu_default"), "default costumes are unlocked after migration")
	_check(store.get_equipped_costumes_by_character().get("dudu", {}).get("outfit", "") == "dudu_default", "default equipment is restored after migration")

	store.data = store._default_data()
	store.data["star_candy_balance"] = 7
	_check(store.save(), "could not persist insufficient-balance fixture")
	_check(not store.unlock_costume("pochacco_detective_hat"), "purchase should fail when the balance is too low")
	_check(store.get_star_candy_balance() == 7, "failed purchase leaves the balance unchanged")
	_check(not store.get_unlocked_costume_ids().has("pochacco_detective_hat"), "failed purchase does not add the costume")

	store.data["star_candy_balance"] = 36
	_check(store.save(), "could not persist purchase fixture")
	_check(store.unlock_costume("dudu_bee_suit"), "affordable costume purchase should succeed")
	_check(store.get_star_candy_balance() == 24, "purchase deducts the catalog price")
	_check(store.get_unlocked_costume_ids().has("dudu_bee_suit"), "purchase adds the ID to the unlocked list")
	_check(store.get_equipped_costumes_by_character().get("dudu", {}).get("outfit", "") == "dudu_default", "unlock does not auto-equip the purchase")
	_check(not store.unlock_costume("dudu_bee_suit"), "duplicate purchase is rejected")
	_check(store.get_star_candy_balance() == 24, "duplicate purchase does not deduct currency")
	_check(store.equip_costume("dudu_bee_suit"), "an unlocked costume can be equipped")
	store.load_save()
	_check(store.get_star_candy_balance() == 24, "balance persists after reload")
	_check(store.get_unlocked_costume_ids().has("dudu_bee_suit"), "unlocked IDs persist after reload")
	_check(store.get_equipped_costumes_by_character().get("dudu", {}).get("outfit", "") == "dudu_bee_suit", "equipped slot persists after reload")
	_check(not store.equip_costume("pochacco_detective_hat"), "locked costume cannot be equipped")
	_check(not store.unlock_costume("not_a_catalog_item"), "unknown costume cannot be purchased")

	var failing_store = FAILING_SAVE_STORE.new()
	failing_store.data = failing_store._default_data()
	failing_store.data["star_candy_balance"] = 36
	_check(not failing_store.unlock_costume("dudu_bee_suit"), "failed disk save rejects a purchase")
	_check(failing_store.get_star_candy_balance() == 36, "failed disk save rolls the balance back")
	_check(not failing_store.get_unlocked_costume_ids().has("dudu_bee_suit"), "failed disk save rolls back the unlocked ID")

	if original_exists:
		_check(_write_text(save_path, original_text), "could not restore the original save file")
	else:
		var absolute_path := ProjectSettings.globalize_path(save_path)
		if FileAccess.file_exists(save_path):
			_check(DirAccess.remove_absolute(absolute_path) == OK, "could not remove temporary save file")
	store.load_save()

	for failure in failures:
		push_error("[COSTUME_SAVE_STORE_FAIL] " + failure)
	if failures.is_empty():
		print("[COSTUME_SAVE_STORE_PASS] v2 migration, balance transactions, unlock/equip persistence and rollback")
	quit(0 if failures.is_empty() else 1)


func _write_json(path: String, value: Dictionary) -> bool:
	return _write_text(path, JSON.stringify(value))


func _write_text(path: String, value: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(value)
	file.close()
	return true


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
