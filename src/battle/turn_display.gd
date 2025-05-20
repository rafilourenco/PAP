extends CanvasLayer

@onready var turn_label: Label = $TurnLabel
@onready var turn_count_label: Label = $TurnCountLabel

func set_turn_info(is_player: bool, turn_number: int) -> void:
    if is_player:
        turn_label.text = tr("GAME_PLAYER_TURN")
    else:
        turn_label.text = tr("GAME_OPPONENT_TURN")
        
    turn_count_label.text = "%s %d" % [tr("GAME_TURN"), turn_number]