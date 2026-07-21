extends Node2D

@onready var game_state = get_node("/root/GameState")

func _ready() -> void:
	var label: Label = $Label
	if game_state.selected_character == "":
		label.text = "No character selected"
	else:
		label.text = "Selected character: %s" % game_state.selected_character
