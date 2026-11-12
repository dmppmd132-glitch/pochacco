extends SceneTree

const CATALOG := preload("res://scripts/costume_catalog.gd")


func _initialize() -> void:
	var errors := CATALOG.validate_current_catalog()
	if not errors.is_empty():
		push_error("[COSTUME_CATALOG_FAIL] " + "; ".join(errors))
		quit(1)
		return
	var defaults := CATALOG.default_unlocked_ids()
	var equipment := CATALOG.default_equipment()
	var total_price := 0
	for costume_id in ["pochacco_detective_hat", "dudu_bee_suit", "dudu_dino_pajamas"]:
		var item := CATALOG.get_costume(costume_id)
		assert(not item.is_empty(), "missing catalog item: " + costume_id)
		total_price += int(item.get("price", 0))
	assert(total_price == 36, "initial prices should match one perfect two-chapter collection")
	assert(CATALOG.is_unlocked("dudu_default", defaults), "Dudu default outfit must be unlocked")
	assert(CATALOG.is_equipped("pochacco_no_hat", equipment), "Pochacco should default to no headwear")
	assert(CATALOG.can_unlock("pochacco_detective_hat", 8, defaults), "8 stars should unlock the detective hat")
	assert(not CATALOG.can_unlock("dudu_dino_pajamas", 15, defaults), "15 stars must not unlock the 16-star pajamas")
	assert(CATALOG.can_unlock("dudu_dino_pajamas", 16, defaults), "16 stars should unlock the pajamas")
	print("[COSTUME_CATALOG_PASS] schema, IDs, prices, defaults, and unlock predicates")
	quit(0)
