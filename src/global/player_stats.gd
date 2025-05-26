extends Node

var play_time := 0.0
var games_played := 0
var units_killed := 0
var battles_won := 0
var battles_lost := 0
var player_units_lost := 0

const SAVE_PATH := "user://player_stats.cfg"

func _process(delta):
	play_time += delta

func add_game_played():
	games_played += 1
	save_stats()

func add_unit_killed():
	units_killed += 1
	save_stats()

func add_battle_won():
	battles_won += 1
	save_stats()

func add_battle_lost():
	battles_lost += 1
	save_stats()

func add_player_unit_lost():
	player_units_lost += 1
	save_stats()

func save_stats():
	var config = ConfigFile.new()
	config.set_value("stats", "play_time", play_time)
	config.set_value("stats", "games_played", games_played)
	config.set_value("stats", "units_killed", units_killed)
	config.set_value("stats", "battles_won", battles_won)
	config.set_value("stats", "battles_lost", battles_lost)
	config.set_value("stats", "player_units_lost", player_units_lost)
	config.save(SAVE_PATH)

func load_stats():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		play_time = config.get_value("stats", "play_time", 0.0)
		games_played = config.get_value("stats", "games_played", 0)
		units_killed = config.get_value("stats", "units_killed", 0)
		battles_won = config.get_value("stats", "battles_won", 0)
		battles_lost = config.get_value("stats", "battles_lost", 0)
		player_units_lost = config.get_value("stats", "player_units_lost", 0)

func send_stats_to_server():
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	var stats = {
		"user_id": Global.player_user_id,
		"play_time": play_time,
		"games_played": games_played,
		"units_killed": units_killed,
		"battles_won": battles_won,
		"battles_lost": battles_lost,
		"player_units_lost": player_units_lost
	}
	var url = "http://localhost/thefellowship/inc/upload_stats.php"
	var json_data = JSON.stringify(stats)
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, HTTPClient.METHOD_POST, json_data)
	http.request_completed.connect(
		func(_result, _response_code, _headers, _body):
			print("Stats upload response code: ", _response_code)
			print("Stats upload response body: ", _body.get_string_from_utf8())
			http.queue_free()
	)

func load_stats_from_server(user_id):
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	var data = {"user_id": user_id}
	var url = "http://localhost/thefellowship/inc/get_stats.php"
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	http.request_completed.connect(_on_stats_loaded_from_server)

func _on_stats_loaded_from_server(result, response_code, headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response:
			play_time = float(response.get("play_time", 0))
			games_played = int(response.get("games_played", 0))
			units_killed = int(response.get("units_killed", 0))
			battles_won = int(response.get("battles_won", 0))
			battles_lost = int(response.get("battles_lost", 0))
			player_units_lost = int(response.get("player_units_lost", 0))
			save_stats()
