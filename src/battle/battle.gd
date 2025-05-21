extends Node2D

@export var tilemap_path: NodePath = NodePath("tiles")
@onready var tiles: TileMap = _find_tilemap()

@onready var units: UnitsContainer = %units

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
