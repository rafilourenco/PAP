extends Panel

@onready var name_label = $VBoxContainer/NameLabel
@onready var email_label = $VBoxContainer/EmailLabel
@onready var play_time_label = $VBoxContainer/GridContainer/PlayTimeValue
@onready var games_played_label = $VBoxContainer/GridContainer/GamesPlayedValue
@onready var units_killed_label = $VBoxContainer/GridContainer/UnitsKilledValue
@onready var battles_won_label = $VBoxContainer/GridContainer/BattlesWonValue
@onready var battles_lost_label = $VBoxContainer/GridContainer/BattlesLostValue
@onready var player_units_lost_label = $VBoxContainer/GridContainer/PlayerUnitsLostValue

func show_account_details():
	name_label.text = Global.player_name
	email_label.text = Global.player_email
	play_time_label.text = str(int(PlayerStats.play_time)) + " s"
	games_played_label.text = str(PlayerStats.games_played)
	units_killed_label.text = str(PlayerStats.units_killed)
	battles_won_label.text = str(PlayerStats.battles_won)
	battles_lost_label.text = str(PlayerStats.battles_lost)
	player_units_lost_label.text = str(PlayerStats.player_units_lost)
