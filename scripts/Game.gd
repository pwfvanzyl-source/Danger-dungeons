extends Control

@onready var game_state = get_node("/root/GameState")

@onready var character_label: Label = $VBoxContainer/CharacterLabel
@onready var turn_label: Label = $VBoxContainer/TurnLabel
@onready var player_stats_label: Label = $VBoxContainer/PlayerStatsLabel
@onready var enemy_stats_label: Label = $VBoxContainer/EnemyStatsLabel
@onready var battle_log_label: RichTextLabel = $VBoxContainer/BattleLogLabel

@onready var attack_button: Button = $VBoxContainer/Buttons/AttackButton
@onready var defend_button: Button = $VBoxContainer/Buttons/DefendButton
@onready var heal_button: Button = $VBoxContainer/Buttons/HealButton
@onready var end_turn_button: Button = $VBoxContainer/Buttons/EndTurnButton
@onready var save_button: Button = $VBoxContainer/Buttons/SaveButton
@onready var quit_button: Button = $VBoxContainer/Buttons/QuitButton

var player_hp: int = 100
var player_max_hp: int = 100
var player_strength: int = 4
var player_shield: int = 0
var current_floor: int = 1
var save_path: String = "user://danger_dungeons_save.dat"
var enemy_name: String = "Slime"
var enemy_hp: int = 50
var enemy_max_hp: int = 50
var enemy_damage: int = 6
var enemy_attack_text: String = "slaps"
var player_turn: bool = true
var battle_active: bool = true

func _ready() -> void:
	randomize()
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	heal_button.pressed.connect(_on_heal_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	save_button.pressed.connect(_on_save_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	player_hp = game_state.player_hp
	player_max_hp = game_state.player_max_hp
	player_strength = game_state.player_strength
	player_shield = game_state.player_shield
	current_floor = game_state.current_floor
	if game_state.selected_character != "":
		game_state.selected_character = game_state.selected_character

	_spawn_enemy()
	_append_log("You are fighting as %s." % [game_state.selected_character if game_state.selected_character != "" else "the hero"])
	_refresh_ui()

func _refresh_ui() -> void:
	var hero_name: String = game_state.selected_character if game_state.selected_character != "" else "Hero"
	character_label.text = "Hero: %s" % hero_name
	turn_label.text = "Turn: %s" % ("Player" if player_turn else "Enemy")
	player_stats_label.text = "Floor %d | You - HP: %d/%d | Strength: %d | Shield: %d" % [current_floor, player_hp, player_max_hp, player_strength, player_shield]
	enemy_stats_label.text = "%s - HP: %d/%d | Damage: %d" % [enemy_name, enemy_hp, enemy_max_hp, enemy_damage]

	attack_button.disabled = not battle_active
	defend_button.disabled = not battle_active
	heal_button.disabled = not battle_active
	end_turn_button.disabled = not battle_active

func _append_log(message: String) -> void:
	battle_log_label.text += message + "\n"

func _spawn_enemy() -> void:
	var enemy_types: Array[Dictionary] = [
		{"name": "Slime", "hp": 50, "damage": 6, "attack_text": "slaps"},
		{"name": "Knight", "hp": 70, "damage": 8, "attack_text": "slashes"},
		{"name": "Lava Slime", "hp": 60, "damage": 10, "attack_text": "burns"},
		{"name": "Slime Commander", "hp": 90, "damage": 12, "attack_text": "commands a crushing strike"}
	]
	var enemy_data: Dictionary = enemy_types[randi() % enemy_types.size()]
	enemy_name = String(enemy_data["name"])
	enemy_max_hp = int(enemy_data["hp"]) + (current_floor - 1) * 5
	enemy_hp = enemy_max_hp
	enemy_damage = int(enemy_data["damage"]) + (current_floor - 1) * 2
	enemy_attack_text = String(enemy_data["attack_text"])
	_append_log("A %s appears on floor %d!" % [enemy_name, current_floor])

func _enemy_turn() -> void:
	if not battle_active:
		return

	var damage: int = enemy_damage
	var blocked: int = 0

	if player_shield > 0:
		blocked = min(player_shield, damage)
		player_shield -= blocked
		damage -= blocked

	if damage > 0:
		player_hp -= damage
		_append_log("The %s %s you for %d damage." % [enemy_name.to_lower(), enemy_attack_text, damage])
	else:
		_append_log("The %s %s, but your shield absorbs the hit." % [enemy_name.to_lower(), enemy_attack_text])

	if blocked > 0:
		_append_log("Your shield absorbs %d damage." % blocked)

	if player_hp <= 0:
		battle_active = false
		_append_log("You were defeated.")
	else:
		player_turn = true

	_refresh_ui()

func _on_attack_pressed() -> void:
	if not battle_active or not player_turn:
		return

	var roll: int = randi_range(1, 6)
	var damage: int = roll + player_strength
	enemy_hp -= damage
	_append_log("You roll %d and deal %d damage." % [roll, damage])

	if enemy_hp <= 0:
		battle_active = false
		_append_log("The enemy falls to the ground.")
		current_floor += 1
		_append_log("You ascend to floor %d." % current_floor)
		player_shield = max(0, player_shield - 1)
		player_hp = min(player_max_hp, player_hp + 8)
		player_turn = true
		_spawn_enemy()
		_refresh_ui()
		return

	player_turn = false
	_refresh_ui()
	_enemy_turn()

func _on_defend_pressed() -> void:
	if not battle_active or not player_turn:
		return

	player_shield += 3
	_append_log("You brace yourself and gain 3 shield.")
	player_turn = false
	_refresh_ui()
	_enemy_turn()

func _on_heal_pressed() -> void:
	if not battle_active or not player_turn:
		return

	var heal_amount: int = 12
	player_hp = min(player_max_hp, player_hp + heal_amount)
	_append_log("You heal %d HP." % heal_amount)
	player_turn = false
	_refresh_ui()
	_enemy_turn()

func _on_end_turn_pressed() -> void:
	if not battle_active or not player_turn:
		return

	_append_log("You pass the turn.")
	player_turn = false
	_refresh_ui()
	_enemy_turn()

func _on_save_pressed() -> void:
	game_state.selected_character = game_state.selected_character
	game_state.current_floor = current_floor
	game_state.player_hp = player_hp
	game_state.player_max_hp = player_max_hp
	game_state.player_strength = player_strength
	game_state.player_shield = player_shield
	game_state.save_to_file(save_path)
	_append_log("Progress saved.")
	_refresh_ui()

func _on_quit_pressed() -> void:
	_on_save_pressed()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
