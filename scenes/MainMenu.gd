extends Control

func _ready() -> void:
	var play_button: Button = $Menu/PlayButton
	var options_button: Button = $Menu/OptionsButton
	var quit_button: Button = $Menu/QuitButton

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	var game_scene: String = "res://scenes/game.tscn"
	var err: int = get_tree().change_scene_to_file(game_scene)
	if err != OK:
		push_error("Failed to change scene to %s" % game_scene)

func _on_options_pressed() -> void:
	print("Options pressed - not implemented yet")

func _on_quit_pressed() -> void:
	get_tree().quit()
