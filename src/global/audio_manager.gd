extends Node

var transition_sound: AudioStreamPlayer

func _ready():
    transition_sound = AudioStreamPlayer.new()
    add_child(transition_sound)

func play_transition_sound(stream: AudioStream):
    transition_sound.stream = stream
    transition_sound.play()