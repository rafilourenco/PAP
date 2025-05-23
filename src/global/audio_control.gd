extends HSlider

@export var audio_bus_name: String
const CONFIG_PATH := "user://settings.cfg"

var audio_bus_id

func _ready():
    audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
    # Load saved volume
    var config = ConfigFile.new()
    if config.load(CONFIG_PATH) == OK:
        var value = config.get_value("audio", audio_bus_name, 1.0)
        self.value = value
        AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(value))
    else:
        AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(self.value))

func _on_value_changed(value:float) -> void:
    var db = linear_to_db(value)
    AudioServer.set_bus_volume_db(audio_bus_id, db)
    # Save volume
    var config = ConfigFile.new()
    config.load(CONFIG_PATH)
    config.set_value("audio", audio_bus_name, value)
    config.save(CONFIG_PATH)
