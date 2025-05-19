class_name UnitsContainer
extends Node2D

# === Properties ===
var groups: Array = []                # All unit groups (player, opponent, etc.)
var current_group: Node               # The group whose turn it is
var current_group_index: int = 0      # Index of the current group
var current_unit_index: int = 0       # Index of the current unit in the group
var current_unit: Unit                # The unit currently taking its turn
var has_moved: bool = false           # Whether the current unit has moved this turn
var has_attacked: bool = false        # Whether the current unit has attacked this turn
var current_acs: Array                # Current available actions (move or attack)
var turn_number: int = 1

func _ready() -> void:
	# Gather all groups (nodes with children) as unit groups
	for child in get_children():
		if child.get_child_count() > 0:
			# Shuffle the order of units in this group for the first game turn
			var children := child.get_children()
			children.shuffle()
			for i in range(children.size()):
				child.move_child(children[i], i)
			groups.append(child)

func start_battle() -> void:
	current_group = groups[0]
	_begin_turn()

func get_active_units() -> Array[Unit]:
	# Return all units with health > 0
	var units: Array[Unit] = []
	for group in groups:
		for child in group.get_children():
			if child.health > 0:
				units.append(child)
	return units

func _unhandled_input(event: InputEvent) -> void:
	# Mouse hover: highlight move path
	if event is InputEventMouseMotion:
		var cell = Navigation.world_to_cell(get_global_mouse_position())
		var match_ac = null
		for ac in current_acs:
			if cell == ac.end_point:
				match_ac = ac
				break
		if not has_moved:
			EventBus.show_move_path.emit(match_ac)
	
	# Mouse click: execute move or attack
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell = Navigation.world_to_cell(get_global_mouse_position())
		for ac in current_acs:
			if cell == ac.end_point:
				if has_moved:
					has_attacked = true
					await _process_attack(ac)
				else:
					current_unit.move_along_path(ac.path + [ac.end_point])
					await current_unit.movement_complete
					has_moved = true
				update_status()
				return

func _process_attack(ac: ActionInstance) -> void:
	# Highlight the attacked cell
	if ac.path.size() > 0:
		EventBus.highlight_attack_cell.emit(ac.path[-1])
	current_unit.attack(ac)
	await current_unit.attack_complete
	# Apply damage to any unit along the attack path (except self)
	for cell in ac.path:
		for group in groups:
			for child in group.get_children():
				if child.cell == cell and child.is_inside_tree() and child != current_unit:
					child.health -= 1
	_check_for_victory()

func _check_for_victory() -> void:
	var player_alive := false
	var opponent_alive := false
	for group in groups:
		if group.name == "player":
			for unit in group.get_children():
				if unit.health > 0:
					player_alive = true
		elif group.name == "opponent":
			for unit in group.get_children():
				if unit.health > 0:
					opponent_alive = true
	if not player_alive or not opponent_alive:
		_show_victory_screen(not player_alive, not opponent_alive)

func _show_victory_screen(player_dead: bool, opponent_dead: bool) -> void:
	# Show result popup
	var msg := ""
	if player_dead and not opponent_dead:
		msg = "GAME_STATUS_YOU_LOSE"
	elif opponent_dead and not player_dead:
		msg = "GAME_STATUS_YOU_WIN"
	else:
		msg = "Draw!"
	var popup := AcceptDialog.new()
	popup.dialog_text = msg
	get_tree().current_scene.add_child(popup)
	popup.connect("confirmed", Callable(self, "_return_to_main_menu"))
	popup.popup_centered()

func _return_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://src/global/main_menu.tscn")

func update_status() -> void:
	# If both moved and attacked, end turn; otherwise, update available actions
	if has_attacked and has_moved:
		has_attacked = false
		has_moved = false
		_step_turn()
	else:
		_update_paths()

func _step_turn() -> void:
	# Prevent infinite recursion if the game is over
	var player_alive := false
	var opponent_alive := false
	for group in groups:
		if group.name == "player":
			for unit in group.get_children():
				if unit.health > 0:
					player_alive = true
		elif group.name == "opponent":
			for unit in group.get_children():
				if unit.health > 0:
					opponent_alive = true
	if not player_alive or not opponent_alive:
		return # Game is over, don't proceed

	# Find the next valid unit to take a turn, looping through all groups and units
	var safety := 0
	while safety < 1000:
		current_unit_index += 1
		if current_unit_index >= current_group.get_child_count():
			current_unit_index = 0
			current_group_index = (current_group_index + 1) % groups.size()
			current_group = groups[current_group_index]
			# Only increment turn_number when returning to the player group
			if current_group.name == "player":
				turn_number += 1
		if current_group.get_child_count() == 0:
			safety += 1
			continue
		var potential_unit = current_group.get_child(current_unit_index)
		if potential_unit.is_inside_tree() and potential_unit.is_active:
			_begin_turn()
			return
		safety += 1
	print("No unit available for next turn.")

func _begin_turn() -> void:
	# Prepare for the next unit's turn
	EventBus.highlight_attack_cell.emit(Vector2(-9999, -9999)) # Hide previous highlight
	current_unit = current_group.get_child(current_unit_index)
	if not current_unit.is_inside_tree() or not current_unit.is_active:
		_step_turn()
		return

	has_attacked = false
	has_moved = false

	# Camera follow logic
	if not current_unit.moved_to_tile.is_connected(_on_unit_moved_to_tile):
		current_unit.moved_to_tile.connect(_on_unit_moved_to_tile)
	var camera = get_tree().current_scene.get_node("Camera2D")
	if camera:
		camera.global_position = current_unit.global_position

	# AI or player turn
	if current_group.name == "opponent":
		await _opponent_ai_turn()
	else:
		_update_paths()
	_update_turn_labels()

func _on_unit_moved_to_tile(pos: Vector2) -> void:
	# Smooth camera follow when unit moves
	var camera = get_tree().current_scene.get_node("Camera2D")
	if camera:
		if camera.has_meta("move_tween"):
			var prev_tween = camera.get_meta("move_tween")
			if is_instance_valid(prev_tween):
				prev_tween.kill()
		var tween = create_tween()
		tween.tween_property(camera, "global_position", pos, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		camera.set_meta("move_tween", tween)

func _opponent_ai_turn() -> void:
	# Simple AI: move toward and attack the closest player unit
	var player_units: Array = []
	for group in groups:
		if group.name == "player":
			for unit in group.get_children():
				if unit.health > 0 and unit.is_inside_tree():
					player_units.append(unit)
	if player_units.is_empty():
		has_attacked = true
		has_moved = true
		update_status()
		return

	# Find the closest player unit
	var closest_player: Unit = player_units[0]
	var min_dist := current_unit.global_position.distance_to(closest_player.global_position)
	for unit in player_units:
		var dist = current_unit.global_position.distance_to(unit.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_player = unit

	# Move as close as possible to the closest player unit
	var move_actions: Array = current_unit.get_move_paths()
	var best_move: ActionInstance = null
	var best_move_dist := min_dist
	for move_ac in move_actions:
		var move_pos = Navigation.cell_to_world(move_ac.end_point, true)
		var dist = move_pos.distance_to(closest_player.global_position)
		if dist < best_move_dist:
			best_move_dist = dist
			best_move = move_ac

	# Move if possible
	if best_move:
		await current_unit.move_along_path(best_move.path + [best_move.end_point])
		has_moved = true

	# Try to attack the closest player unit, or the tile closest to them
	var attack_actions: Array = current_unit.get_attack_paths()
	var best_attack: ActionInstance = null
	var best_attack_dist := INF
	for attack_ac in attack_actions:
		# Prefer attacking the player if possible
		if closest_player.cell == attack_ac.end_point:
			best_attack = attack_ac
			break
		# Otherwise, find the attack action closest to the player
		var attack_pos = Navigation.cell_to_world(attack_ac.end_point, true)
		var dist = attack_pos.distance_to(closest_player.global_position)
		if dist < best_attack_dist:
			best_attack_dist = dist
			best_attack = attack_ac

	if best_attack:
		has_attacked = true
		await _process_attack(best_attack)
	else:
		has_attacked = true  # Ensure the turn ends even if no attack

	has_moved = true # AI always ends its turn after acting
	update_status()

func _update_turn_labels() -> void:
	# Update the turn display UI
	var turn_display = get_tree().current_scene.get_node("TurnDisplay")
	if turn_display:
		turn_display.set_turn_info(current_group.name == "player", turn_number)

func _update_paths() -> void:
	# Update available actions for the current unit
	EventBus.show_move_path.emit(null)
	if has_moved:
		current_acs = current_unit.get_attack_paths()
		EventBus.show_attack_acs.emit(current_acs)
		EventBus.show_move_acs.emit([])
		return
	current_acs = current_unit.get_move_paths()
	EventBus.show_move_acs.emit(current_acs)
	EventBus.show_attack_acs.emit([])


func _score_action(move_ac, attack_ac, closest_unit) -> float:
	# Score a potential move/attack for AI decision-making
	var score := 0.0

	# Small benefit for moving closer to the closest player
	if move_ac:
		var move_end = Navigation.cell_to_world(move_ac.end_point, true)
		var dist = move_end.distance_to(closest_unit.global_position)
		score += 0.01 * (100 - dist)

	if attack_ac:
		var target_unit = null
		# Find the unit at the attack's end point
		for group in groups:
			for unit in group.get_children():
				if unit.cell == attack_ac.end_point and unit.is_inside_tree():
					target_unit = unit
					break
		if target_unit:
			var is_friendly = (groups.find(target_unit.get_parent()) == groups.find(current_group))
			var will_kill = (target_unit.health <= 1)
			if is_friendly:
				score -= 1000 # Never attack friendlies
			else:
				score += 1000 # Always attack player if possible
				if will_kill:
					score += 100 # Prefer killing
				score += (10 / max(target_unit.health, 1)) # Prefer attacking weakest
		else:
			# Attacking empty tile, small benefit for being close to player
			var attack_pos = Navigation.cell_to_world(attack_ac.end_point, true)
			var dist = attack_pos.distance_to(closest_unit.global_position)
			score += 0.01 * (100 - dist)
	return score
