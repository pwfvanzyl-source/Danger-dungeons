extends Node
class_name GameState

var selected_character: String = ""
var save_slot: int = 0
var current_floor: int = 1
var player_hp: int = 100
var player_max_hp: int = 100
var player_strength: int = 4
var player_shield: int = 0
var save_path: String = "user://danger_dungeons_save.dat"

func reset() -> void:
	selected_character = ""
	save_slot = 0
	current_floor = 1
	player_hp = 100
	player_max_hp = 100
	player_strength = 4
	player_shield = 0

func save_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write save file: %s" % path)
		return
	file.store_var(selected_character)
	file.store_var(save_slot)
	file.store_var(current_floor)
	file.store_var(player_hp)
	file.store_var(player_max_hp)
	file.store_var(player_strength)
	file.store_var(player_shield)
	file.close()

func load_from_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not read save file: %s" % path)
		return false
	selected_character = file.get_var()
	save_slot = file.get_var()
	current_floor = file.get_var()
	player_hp = file.get_var()
	player_max_hp = file.get_var()
	player_strength = file.get_var()
	player_shield = file.get_var()
	file.close()
	return true
