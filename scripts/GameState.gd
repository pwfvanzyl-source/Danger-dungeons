extends Node
class_name GameState

var selected_character: String = ""
var save_slot: int = 0

func reset() -> void:
	selected_character = ""
	save_slot = 0
