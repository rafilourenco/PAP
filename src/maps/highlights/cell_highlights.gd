extends Node2D

const HIGHLIGHT_STROKED = preload('res://src/maps/highlights/cell_highlight.png')
const HIGHLIGHT_STROKE_ONLY = preload('res://src/maps/highlights/cell_highlight_stroke_only.png')
const HIGHLIGHT_FILL = preload('res://src/maps/highlights/cell_highlight_no_stroke.png')

@onready var paths_fill: Node2D = $paths_fill
@onready var paths_highlights: Node2D = $paths
@onready var attacks_highlights: Node2D = $attacks
@onready var mouse_highlight: Sprite2D = $mouse_highlight

var attack_highlight_sprite: Sprite2D = null
var attack_highlight_tween: Tween = null

func _ready() -> void:
	EventBus.show_move_acs.connect(_on_show_move_acs)
	EventBus.show_attack_acs.connect(_on_show_attack_acs)
	EventBus.show_move_path.connect(_on_show_move_path)
	EventBus.highlight_attack_cell.connect(_on_highlight_attack_cell)

func _process(delta: float) -> void:
	mouse_highlight.global_position = Navigation.snap_to_tile(get_global_mouse_position())

func _on_show_attack_acs(acs: Array) -> void:
	for child in attacks_highlights.get_children():
		child.queue_free()
	
	for ac in acs:
		for cell in ac.path:
			add_highlight(Color(1.0, 0.5, 0.0, 0.5), Navigation.cell_to_world(cell), attacks_highlights, HIGHLIGHT_FILL)
		add_highlight(Color(1.0, 0.5, 0.0, 0.5), Navigation.cell_to_world(ac.end_point), attacks_highlights, HIGHLIGHT_FILL)
		add_highlight(Color(1.0, 0.5, 0.0, 1.0), Navigation.cell_to_world(ac.end_point), attacks_highlights, HIGHLIGHT_STROKE_ONLY)
		

func _on_show_move_acs(acs: Array) -> void:
	for child in paths_highlights.get_children():
		child.queue_free()
	
	for ac in acs:
		add_highlight(Color(0.0, 0.75, 1.0, 1.0), Navigation.cell_to_world(ac.end_point), paths_highlights, HIGHLIGHT_STROKE_ONLY)

func _on_show_move_path(ac: ActionInstance) -> void:
	for child in paths_fill.get_children():
		child.queue_free()
	
	if ac:
		for cell in ac.path:
			add_highlight(Color(0.0, 0.5, 1.0, 0.5), Navigation.cell_to_world(cell), paths_fill, HIGHLIGHT_FILL)

func _on_highlight_attack_cell(cell: Vector2) -> void:
	# Remove previous highlight if any
	if attack_highlight_sprite and is_instance_valid(attack_highlight_sprite):
		attack_highlight_sprite.queue_free()
		attack_highlight_sprite = null
	if attack_highlight_tween and is_instance_valid(attack_highlight_tween):
		attack_highlight_tween.kill()
		attack_highlight_tween = null

	# If cell is invalid, do nothing
	if cell.x < -9000:
		return

	# Add new red outline
	attack_highlight_sprite = Sprite2D.new()
	attack_highlight_sprite.texture = HIGHLIGHT_STROKE_ONLY
	attack_highlight_sprite.modulate = Color(1, 0, 0, 1) # Red
	attack_highlight_sprite.centered = false
	attack_highlight_sprite.global_position = Navigation.cell_to_world(cell)
	add_child(attack_highlight_sprite)

	# Fade out over 3 seconds
	attack_highlight_tween = create_tween()
	attack_highlight_tween.tween_property(attack_highlight_sprite, "modulate:a", 0.0, 3.0)
	attack_highlight_tween.tween_callback(Callable(attack_highlight_sprite, "queue_free"))

func add_highlight(color: Color, pos: Vector2, parent: Node, tex: Texture) -> void:
	var s = Sprite2D.new()
	s.texture = tex
	parent.add_child(s)
	s.centered = false
	s.global_position = pos
	s.modulate = color
