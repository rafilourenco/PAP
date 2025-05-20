extends CheckButton

const CONFIG_PATH := "user://settings.cfg"

func _ready() -> void:
    var config = ConfigFile.new()
    if config.load(CONFIG_PATH) == OK:
        var vsync_enabled = config.get_value("window", "vsync", true)
        button_pressed = vsync_enabled
        _set_vsync(vsync_enabled)
    else:
        button_pressed = true
        _set_vsync(true)

func _on_toggled(toggled_on: bool) -> void:
    _set_vsync(toggled_on)
    var config = ConfigFile.new()
    config.load(CONFIG_PATH)
    config.set_value("window", "vsync", toggled_on)
    config.save(CONFIG_PATH)

func _set_vsync(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)