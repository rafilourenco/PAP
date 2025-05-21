extends Panel

func _play_random_level_scene(level_number: int):
    var level_path = "res://src/levels/level%d/" % level_number
    var dir = DirAccess.open(level_path)
    var scenes = []
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tscn"):
                scenes.append(level_path + file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
    if scenes.size() > 0:
        var random_scene = scenes[randi() % scenes.size()]
        AudioManager.play_transition_sound(load("res://src/global/sounds/whoosh_battle_sound.mp3"))
        get_tree().change_scene_to_file(random_scene)

func _on_level1_play_pressed():
    AudioManager.play_transition_sound(load("res://src/global/sounds/whoosh_battle_sound.mp3"))
    _play_random_level_scene(1)
    