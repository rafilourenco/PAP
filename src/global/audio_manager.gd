extends Node

var transition_sound: AudioStreamPlayer
var click_sound: AudioStreamPlayer

func _ready():
    transition_sound = AudioStreamPlayer.new()
    transition_sound.bus = "SFX"
    add_child(transition_sound)
    click_sound = AudioStreamPlayer.new()
    click_sound.bus = "SFX"
    add_child(click_sound)

func play_transition_sound(stream: AudioStream):
    transition_sound.stream = stream
    transition_sound.play()

func play_click_sound(stream: AudioStream):
    click_sound.stream = stream
    click_sound.play()