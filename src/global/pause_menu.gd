extends Control

signal resume_requested
signal restart_requested
signal options_requested
signal main_menu_requested

@onready var main_panel = $MainPanel
@onready var options_panel = $OptionsPanel
@onready var language_dropdown: OptionButton = find_child("LanguageDropdown", true, false)
@onready var flag_image: TextureRect = find_child("FlagImage", true, false)

const CONFIG_PATH := "user://settings.cfg"

var language_flags = {
    "ENGLISH": "res://src/global/flags/united_kingdom_32.png",
    "FRENCH": "res://src/global/flags/france_32.png",
    "SPANISH": "res://src/global/flags/spain_32.png",
    "GERMAN": "res://src/global/flags/germany_32.png",
    "ITALIAN": "res://src/global/flags/italy_32.png",
    "PORTUGUESE": "res://src/global/flags/portugal_32.png",
    "RUSSIAN": "res://src/global/flags/russia_32.png",
    "GREEK": "res://src/global/flags/greece_32.png",
    "TURKISH": "res://src/global/flags/turkiye_32.png",
    "DANISH": "res://src/global/flags/denmark_32.png",
    "NORWEGIAN": "res://src/global/flags/norway_32.png",
    "SWEDISH": "res://src/global/flags/sweden_32.png",
    "DUTCH": "res://src/global/flags/netherlands_32.png",
    "POLISH": "res://src/global/flags/poland_32.png",
    "FINNISH": "res://src/global/flags/finland_32.png",
    "JAPANESE": "res://src/global/flags/japan_32.png",
    "SIMPLIFIED": "res://src/global/flags/china_32.png",
    "TRADITIONAL": "res://src/global/flags/china_32.png",
    "KOREAN": "res://src/global/flags/south_korea_32.png",
    "CZECH": "res://src/global/flags/czech_32.png",
    "HUNGARIAN": "res://src/global/flags/hungary_32.png",
    "ROMANIAN": "res://src/global/flags/romania_32.png",
    "THAI": "res://src/global/flags/thailand_32.png",
    "BULGARIAN": "res://src/global/flags/bulgaria_32.png",
    "HEBREW": "res://src/global/flags/israel_32.png",
    "ARABIC": "res://src/global/flags/saudi_arabia_32.png"
}

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

func _ready():
    main_panel.visible = true
    options_panel.visible = false
    var lang = load_language()
    TranslationServer.set_locale(lang)
    set_global_font_for_language(lang)
    _setup_language_dropdown()

func _setup_language_dropdown():
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
    var lang = TranslationServer.get_locale().to_upper()
    var idx := 0
    for i in language_dropdown.item_count:
        if language_dropdown.get_item_text(i) == lang:
            idx = i
            break
    language_dropdown.select(idx)
    language_dropdown.connect("item_selected", Callable(self, "_on_language_dropdown_item_selected"))
    _update_flag_image(lang)

func _on_language_dropdown_item_selected(index: int) -> void:
    var lang = language_dropdown.get_item_text(index)
    TranslationServer.set_locale(lang)
    save_language(lang)
    set_global_font_for_language(lang)
    _update_flag_image(lang)

func _update_flag_image(lang: String) -> void:
    if language_flags.has(lang):
        flag_image.texture = load(language_flags[lang])

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
