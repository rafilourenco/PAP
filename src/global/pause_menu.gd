extends Control

signal resume_requested
signal restart_requested
signal options_requested
signal main_menu_requested

@onready var main_panel = $MainPanel
@onready var options_panel = $OptionsPanel

func _ready():
	main_panel.visible = true
	options_panel.visible = false

func _on_Continue_pressed():
	emit_signal("resume_requested")

func _on_Restart_pressed():
	emit_signal("restart_requested")

func _on_Options_pressed():
	main_panel.visible = false
	options_panel.visible = true

func _on_MainMenu_pressed():
	emit_signal("main_menu_requested")

func _on_BackOptions_pressed():
	options_panel.visible = false
	main_panel.visible = true
