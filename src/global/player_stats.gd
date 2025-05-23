extends Node

var play_time := 0.0
var games_played := 0
var units_killed := 0

const SAVE_PATH := "user://player_stats.cfg"

func _process(delta):
	play_time += delta

func add_game_played():
	games_played += 1
	save_stats()

func add_unit_killed():
	units_killed += 1
	save_stats()

func save_stats():
	var config = ConfigFile.new()
	config.set_value("stats", "play_time", play_time)
	config.set_value("stats", "games_played", games_played)
	config.set_value("stats", "units_killed", units_killed)
	config.save(SAVE_PATH)

func load_stats():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		play_time = config.get_value("stats", "play_time", 0.0)
		games_played = config.get_value("stats", "games_played", 0)
		units_killed = config.get_value("stats", "units_killed", 0)

func send_stats_to_server():
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)
	var stats = {
		"play_time": play_time,
		"games_played": games_played,
		"units_killed": units_killed
	}
	var url = "https://thefellowship.rf.gd/inc/upload_stats.php"
	var json_data = JSON.stringify(stats)
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, HTTPClient.METHOD_POST, json_data)
	http.request_completed.connect(
		func(_result, _response_code, _headers, _body):
			print("Stats upload response code: ", _response_code)
			print("Stats upload response body: ", _body.get_string_from_utf8())
			http.queue_free()
	)
