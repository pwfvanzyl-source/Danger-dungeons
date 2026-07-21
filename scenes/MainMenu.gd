extends Control

@onready var game_state = get_node("/root/GameState")
var main_menu_container: VBoxContainer
var save_slots_panel: PanelContainer
var save_slots_container: VBoxContainer
var character_selection_panel: PanelContainer
var character_buttons_container: VBoxContainer
var selected_slot: int = 0
const CHARACTER_LIST = ["Charlie", "Goob", "Marshy", "Liken", "Fromo"]

func _ready() -> void:
	main_menu_container = $Menu
	save_slots_panel = $SaveSlotsPanel
	save_slots_container = $SaveSlotsPanel/VBoxContainer
	character_selection_panel = $CharacterSelectionPanel
	character_buttons_container = $CharacterSelectionPanel/VBoxContainer

	var play_button: Button = $Menu/PlayButton
	var options_button: Button = $Menu/OptionsButton
	var quit_button: Button = $Menu/QuitButton
	var back_button: Button = $SaveSlotsPanel/VBoxContainer/BackButton
	var char_back_button: Button = $CharacterSelectionPanel/VBoxContainer/BackButton

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	char_back_button.pressed.connect(_on_character_back_pressed)

	for slot_index in range(1, 4):
		var slot_button: Button = save_slots_container.get_node("Slot%sButton" % slot_index)
		slot_button.pressed.connect(_on_save_slot_pressed.bind(slot_index))

	for character_name in CHARACTER_LIST:
		var character_button: Button = character_buttons_container.get_node("%sButton" % character_name)
		character_button.pressed.connect(_on_character_pressed.bind(character_name))

	show_main_menu()

func show_main_menu() -> void:
	main_menu_container.visible = true
	save_slots_panel.visible = false
	character_selection_panel.visible = false

func show_save_slots() -> void:
	main_menu_container.visible = false
	save_slots_panel.visible = true
	character_selection_panel.visible = false

func show_character_selection(slot_index: int) -> void:
	selected_slot = slot_index
	main_menu_container.visible = false
	save_slots_panel.visible = false
	character_selection_panel.visible = true

func _on_play_pressed() -> void:
	show_save_slots()

func _on_save_slot_pressed(slot_index: int) -> void:
	print("Selected save slot %d" % slot_index)
	show_character_selection(slot_index)

func _on_character_pressed(character_name: String) -> void:
	print("Selected character %s for slot %d" % [character_name, selected_slot])
	game_state.selected_character = character_name
	game_state.save_slot = selected_slot
	var game_scene: String = "res://scenes/game.tscn"
	var err: int = get_tree().change_scene_to_file(game_scene)
	if err != OK:
		push_error("Failed to change scene to %s" % game_scene)

func _on_back_pressed() -> void:
	show_main_menu()

func _on_character_back_pressed() -> void:
	show_save_slots()

func _on_options_pressed() -> void:
	print("Options pressed - not implemented yet")

func _on_quit_pressed() -> void:
	get_tree().quit()
