extends Control

const CONFIG_PATH := "user://settings.cfg"
@onready var main_buttons: Panel = $MainButtons
@onready var options: Panel = $Options

func save_language(lang: String) -> void:
	var config = ConfigFile.new()
	config.set_value("locale", "language", lang)
	config.save(CONFIG_PATH)

func load_language() -> String:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		return config.get_value("locale", "language", "PORTUGUESE")
	return "PORTUGUESE"

func load_window_mode() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		var mode = config.get_value("window", "mode", "windowed")
		if mode == "fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready() -> void:
	var lang = load_language()
	TranslationServer.set_locale(lang)
	load_window_mode()
	main_buttons.visible = true
	options.visible = false


func _process(delta: float) -> void:
	pass

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://src/battle/battle.tscn")

func _on_opcoes_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_sair_pressed() -> void:
	get_tree().quit()

func _on_english_button_pressed() -> void:
	TranslationServer.set_locale("ENGLISH")
	save_language("ENGLISH")

func _on_italian_button_pressed() -> void:
	TranslationServer.set_locale("ITALIAN")
	save_language("ITALIAN")

func _on_french_button_pressed() -> void:
	TranslationServer.set_locale("FRENCH")
	save_language("FRENCH")

func _on_german_button_pressed() -> void:
	TranslationServer.set_locale("GERMAN")
	save_language("GERMAN")
	
func _on_back_options_pressed() -> void:
	main_buttons.visible = true
	options.visible = false
