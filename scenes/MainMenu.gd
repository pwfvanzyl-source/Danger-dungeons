extends Control

func _ready() -> void:
    # Connect buttons (Godot 4 style)
    var play = $Menu/PlayButton
    var options = $Menu/OptionsButton
    var quit = $Menu/QuitButton
    if play:
        if hasattr(play, "pressed"):
            play.pressed.connect(_on_play_pressed)
        else:
            play.connect("pressed", Callable(self, "_on_play_pressed"))
    if options:
        if hasattr(options, "pressed"):
            options.pressed.connect(_on_options_pressed)
        else:
            options.connect("pressed", Callable(self, "_on_options_pressed"))
    if quit:
        if hasattr(quit, "pressed"):
            quit.pressed.connect(_on_quit_pressed)
        else:
            quit.connect("pressed", Callable(self, "_on_quit_pressed"))


func _on_play_pressed() -> void:
    var game_scene = "res://scenes/game.tscn"
    var err = get_tree().change_scene_to_file(game_scene)
    if err != OK:
        push_error("Failed to change scene to %s" % game_scene)


func _on_options_pressed() -> void:
    # TODO: implement options UI
    print("Options pressed - not implemented yet")


func _on_quit_pressed() -> void:
    get_tree().quit()
