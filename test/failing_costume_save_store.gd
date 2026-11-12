extends "res://scripts/save_store.gd"


func save() -> bool:
	last_save_ok = false
	save_failed.emit()
	return false
