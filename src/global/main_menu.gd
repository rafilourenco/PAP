extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TranslationServer.set_locale("PORTUGUESE")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://src/battle/battle.tscn")


func _on_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://src/global/options_menu.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_english_button_pressed() -> void:
	TranslationServer.set_locale("ENGLISH")
	
func _on_italian_button_pressed() -> void:
	TranslationServer.set_locale("ITALIAN")
	
func _on_french_button_pressed() -> void:
	TranslationServer.set_locale("FRENCH")
	
func _on_german_button_pressed() -> void:
	TranslationServer.set_locale("GERMAN")
	
