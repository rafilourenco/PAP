extends Control

const CONFIG_PATH := "user://settings.cfg"
@onready var main_buttons: Panel = $MainButtons
@onready var options: Panel = $Options
@onready var language_dropdown: OptionButton = $LanguageDropdown

func save_language(lang: String) -> void:
	var config = ConfigFile.new()
	config.set_value("locale", "language", lang)
	config.save(CONFIG_PATH)

func load_language() -> String:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		return config.get_value("locale", "language", "PORTUGUESE")
	return "PORTUGUESE"

func set_global_font_for_language(lang: String) -> void:
	var theme = Theme.new()
	var font: FontFile

	match lang:
		"JAPANESE":
			font = load("res://src/global/fonts/NotoSansJP-Regular.ttf")
		"SIMPLIFIED":
			font = load("res://src/global/fonts/NotoSansSC-Regular.ttf")
		"TRADITIONAL":
			font = load("res://src/global/fonts/NotoSansTC-Regular.ttf")
		"KOREAN":
			font = load("res://src/global/fonts/NotoSansKR-Regular.ttf")
		"ARABIC":
			font = load("res://src/global/fonts/NotoSansArabic-Regular.ttf")
		"THAI":
			font = load("res://src/global/fonts/NotoSansThai-Regular.ttf")
		"HEBREW":
			font = load("res://src/global/fonts/NotoSansHebrew-Regular.ttf")
		_:
			font = load("res://src/global/fonts/NotoSans-Regular.ttf")

	theme.set_default_font(font)
	get_tree().root.theme = theme

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
	set_global_font_for_language(lang)
	load_window_mode()
	main_buttons.visible = true
	options.visible = false

	language_dropdown.clear()
	language_dropdown.add_item("ENGLISH")
	language_dropdown.add_item("FRENCH")
	language_dropdown.add_item("SPANISH")
	language_dropdown.add_item("GERMAN")
	language_dropdown.add_item("ITALIAN")
	language_dropdown.add_item("PORTUGUESE")
	language_dropdown.add_item("RUSSIAN")
	language_dropdown.add_item("GREEK")
	language_dropdown.add_item("TURKISH")
	language_dropdown.add_item("DANISH")
	language_dropdown.add_item("NORWEGIAN")
	language_dropdown.add_item("SWEDISH")
	language_dropdown.add_item("DUTCH")
	language_dropdown.add_item("POLISH")
	language_dropdown.add_item("FINNISH")
	language_dropdown.add_item("JAPANESE")
	language_dropdown.add_item("SIMPLIFIED")
	language_dropdown.add_item("TRADITIONAL")
	language_dropdown.add_item("KOREAN")
	language_dropdown.add_item("CZECH")
	language_dropdown.add_item("HUNGARIAN")
	language_dropdown.add_item("ROMANIAN")
	language_dropdown.add_item("THAI")	
	language_dropdown.add_item("BULGARIAN")
	language_dropdown.add_item("HEBREW")
	language_dropdown.add_item("ARABIC")


	# Set current language as selected
	var idx := 0
	for i in language_dropdown.item_count:
		if language_dropdown.get_item_text(i) == lang:
			idx = i
			break
	language_dropdown.select(idx)

	language_dropdown.connect("item_selected", Callable(self, "_on_language_dropdown_item_selected"))

func _process(delta: float) -> void:
	pass

func _on_jogar_pressed() -> void:
	AudioManager.play_transition_sound(load("res://src/global/whoosh_battle_sound.mp3"))
	get_tree().change_scene_to_file("res://src/battle/battle.tscn")

func _on_opcoes_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_sair_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_language_dropdown_item_selected(index: int) -> void:
	var lang = language_dropdown.get_item_text(index)
	TranslationServer.set_locale(lang)
	save_language(lang)
	set_global_font_for_language(lang)
