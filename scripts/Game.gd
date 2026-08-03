extends Control

@onready var game_state = get_node("/root/GameState")

@onready var character_label: Label = $VBoxContainer/CharacterLabel
@onready var turn_label: Label = $VBoxContainer/TurnLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
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
var enemy_name: String = "Slime"
var enemy_hp: int = 50
var enemy_max_hp: int = 50
var enemy_damage: int = 6
var enemy_attack_text: String = "slaps"
var player_turn: bool = true
var battle_active: bool = true
var player_poisoned: bool = false
var player_burned: bool = false
var enemy_stunned: bool = false
var enemy_armor: int = 0
var turn_count: int = 0

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
	_append_log("The dungeon is tense. Choose your move carefully.")
	_refresh_ui()

func _refresh_ui() -> void:
	var hero_name: String = game_state.selected_character if game_state.selected_character != "" else "Hero"
	character_label.text = "Hero: %s" % hero_name
	turn_label.text = "Turn: %s" % ("Player" if player_turn else "Enemy")
	status_label.text = "Status: %s" % _build_status_string()
	player_stats_label.text = "Floor %d | You - HP: %d/%d | Strength: %d | Shield: %d" % [current_floor, player_hp, player_max_hp, player_strength, player_shield]
	enemy_stats_label.text = "%s - HP: %d/%d | Damage: %d | Armor: %d" % [enemy_name, enemy_hp, enemy_max_hp, enemy_damage, enemy_armor]

	attack_button.disabled = not battle_active or not player_turn
	defend_button.disabled = not battle_active or not player_turn
	heal_button.disabled = not battle_active or not player_turn
	end_turn_button.disabled = not battle_active or not player_turn

func _append_log(message: String) -> void:
	battle_log_label.text += message + "\n"

func _build_status_string() -> String:
	var parts: Array[String] = []
	if player_poisoned:
		parts.append("Poisoned")
	if player_burned:
		parts.append("Burned")
	if enemy_stunned:
		parts.append("Enemy Stunned")
	if parts.is_empty():
		return "None"
	return ", ".join(parts)

func _spawn_enemy() -> void:
	var enemy_types: Array[Dictionary] = [
		{"name": "Slime", "hp": 50, "damage": 6, "attack_text": "slaps"},
		{"name": "Knight", "hp": 70, "damage": 8, "attack_text": "slashes"},
		{"name": "Lava Slime", "hp": 60, "damage": 10, "attack_text": "burns"},
		{"name": "Slime Commander", "hp": 90, "damage": 12, "attack_text": "commands a crushing strike"}
	]
	if current_floor <= 20:
		enemy_types = [enemy_types[0]]
	var enemy_data: Dictionary = enemy_types[randi() % enemy_types.size()]
	enemy_name = String(enemy_data["name"])
	enemy_max_hp = int(enemy_data["hp"]) + (current_floor - 1) * 5
	enemy_hp = enemy_max_hp
	enemy_damage = int(enemy_data["damage"]) + (current_floor - 1) * 2
	enemy_attack_text = String(enemy_data["attack_text"])
	enemy_armor = 0
	enemy_stunned = false
	turn_count = 0
	if current_floor % 3 == 0:
		enemy_armor = 3
		_append_log("The %s enters the floor with extra armor." % enemy_name.to_lower())
	_append_log("A %s appears on floor %d!" % [enemy_name, current_floor])

func _enemy_turn() -> void:
	if not battle_active:
		return

	turn_count += 1
	if enemy_stunned:
		_append_log("The %s is stunned and skips its turn." % enemy_name.to_lower())
		enemy_stunned = false
		player_turn = true
		_refresh_ui()
		return

	var damage: int = max(0, enemy_damage - enemy_armor)
	var blocked: int = 0

	if player_shield > 0:
		blocked = min(player_shield, damage)
		player_shield -= blocked
		damage -= blocked

	if damage > 0:
		player_hp = max(0, player_hp - damage)
		_append_log("The %s %s you for %d damage." % [enemy_name.to_lower(), enemy_attack_text, damage])
	else:
		_append_log("The %s %s, but your shield absorbs the hit." % [enemy_name.to_lower(), enemy_attack_text])

	if blocked > 0:
		_append_log("Your shield absorbs %d damage." % blocked)

	if player_hp <= 0:
		battle_active = false
		_append_log("You were defeated.")
		if game_state.save_slot > 0:
			game_state.delete_save(game_state.get_slot_path(game_state.save_slot))
			_append_log("Your save has been deleted.")
	else:
		player_turn = true
		if turn_count % 3 == 0:
			player_poisoned = true
			_append_log("The %s leaves a poisonous residue on the floor." % enemy_name.to_lower())
		if turn_count % 4 == 0:
			player_burned = true
			_append_log("The %s scorches the battlefield." % enemy_name.to_lower())

	_refresh_ui()

func _on_attack_pressed() -> void:
	if not battle_active or not player_turn:
		return

	var roll: int = randi_range(1, 6)
	var damage: int = roll + player_strength
	if player_poisoned:
		damage += 2
		_append_log("Poison amplifies your attack.")
	if player_burned:
		player_burned = false
		_append_log("The burn clears as you act.")
	enemy_hp = max(0, enemy_hp - damage)
	_append_log("You roll %d and deal %d damage." % [roll, damage])

	if enemy_hp <= 0:
		battle_active = false
		_append_log("The enemy falls to the ground.")
		current_floor += 1
		_append_log("You ascend to floor %d." % current_floor)
		player_shield = max(0, player_shield - 1)
		player_hp = min(player_max_hp, player_hp + 8)
		player_turn = true
		player_poisoned = false
		player_burned = false
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
	enemy_stunned = true
	_append_log("Your defense rattles the enemy and leaves it stunned.")
	player_turn = false
	_refresh_ui()
	_enemy_turn()

func _on_heal_pressed() -> void:
	if not battle_active or not player_turn:
		return

	var heal_amount: int = 12
	player_hp = min(player_max_hp, player_hp + heal_amount)
	_append_log("You heal %d HP." % heal_amount)
	player_poisoned = false
	player_burned = false
	player_turn = false
	_refresh_ui()
	_enemy_turn()

func _on_end_turn_pressed() -> void:
	if not battle_active or not player_turn:
		return

	_append_log("You pass the turn.")
	if player_poisoned:
		player_hp = max(0, player_hp - 2)
		_append_log("The poison ticks for 2 damage.")
	if player_burned:
		player_hp = max(0, player_hp - 3)
		_append_log("The burn deals 3 damage.")
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
	if game_state.save_slot <= 0:
		game_state.save_slot = 1
		_append_log("No save slot selected, defaulting to slot 1.")
	game_state.save_to_file(game_state.get_slot_path(game_state.save_slot))
	_append_log("Progress saved to slot %d." % game_state.save_slot)
	_refresh_ui()

func _on_quit_pressed() -> void:
	_on_save_pressed()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
