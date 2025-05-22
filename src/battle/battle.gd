extends Node2D

@export var tilemap_path: NodePath = NodePath("tiles")
@onready var tiles: TileMap = _find_tilemap()
@onready var units: UnitsContainer = %units
@onready var pause_menu: Control = $PauseMenu # Add this line

func _find_tilemap() -> TileMap:
	if has_node(tilemap_path):
		var node = get_node(tilemap_path)
		if node is TileMap:
			return node
	# Fallback: search for first TileMap in children
	for child in get_children():
		if child is TileMap:
			return child
		# Search recursively
		var found = child.find_child("", true, false)
		if found and found is TileMap:
			return found
	push_error("No TileMap found in scene!")
	return null

func _ready() -> void:
	print("tiles node: ", tiles)
	Navigation.init_level(tiles, units.get_active_units)
	units.start_battle()
	# --- Pause menu setup ---
	pause_menu.visible = false
	pause_menu.connect("resume_requested", Callable(self, "_hide_pause_menu"))
	pause_menu.connect("restart_requested", Callable(self, "_on_restart_requested"))
	pause_menu.connect("main_menu_requested", Callable(self, "_on_main_menu_requested"))
	pause_menu.connect("options_requested", Callable(self, "_on_options_requested"))

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC by default
		_show_pause_menu()

func _show_pause_menu():
	get_tree().paused = true
	pause_menu.visible = true

func _hide_pause_menu():
	get_tree().paused = false
	pause_menu.visible = false

func _on_restart_requested():
	get_tree().paused = false
	get_tree().reload_current_scene() # This restarts the current level scene

func _on_main_menu_requested():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/global/main_menu.tscn")

func _on_options_requested():
	get_tree().paused = false
	pause_menu.visible = false
	# Show the options menu (assuming you have it as a scene or node)
	var options_menu = get_node("/root/MAIN/Options_Menu") # Adjust path as needed
	options_menu.visible = true
