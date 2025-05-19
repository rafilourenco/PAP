extends CheckButton

const CONFIG_PATH := "user://settings.cfg"

func _ready() -> void:
    var config = ConfigFile.new()
    if config.load(CONFIG_PATH) == OK:
        var mode = config.get_value("window", "mode", "windowed")
        button_pressed = (mode == "fullscreen")
    else:
        button_pressed = false

func _on_toggled(toggled_on:bool) -> void:
    var config = ConfigFile.new()
    config.load(CONFIG_PATH) # Load existing config!
    if toggled_on:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
        config.set_value("window", "mode", "fullscreen")
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        config.set_value("window", "mode", "windowed")
    config.save(CONFIG_PATH)
