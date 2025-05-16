extends CanvasLayer

@onready var turn_label: Label = $TurnLabel
@onready var turn_count_label: Label = $TurnCountLabel

func set_turn_info(is_player: bool, turn_number: int) -> void:
    if is_player:
        turn_label.text = "PLAYER'S TURN"
    else:
        turn_label.text = "OPPONENT'S TURN"
    turn_count_label.text = "Turn %d" % turn_number