extends Panel

@onready var email_field = $VBoxContainer/EmailLineEdit
@onready var password_field = $VBoxContainer/PasswordLineEdit
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var login_button = $VBoxContainer/LoginButton

func _ready():
	login_button.pressed.connect(_on_login_button_pressed)

func _on_login_button_pressed():
	var email = email_field.text
	var password = password_field.text
	var password_hash = password.md5_text() # Hash the password here
	var http = HTTPRequest.new()
	add_child(http)
	var data = {"email": email, "password": password_hash} # Send the hash, not the plain password
	print("Sending login data: ", data)
	http.request(
		"http://localhost/thefellowship/inc/api_login.php",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)
	http.request_completed.connect(_on_login_response)

func _on_login_response(result, response_code, headers, body):
	print("Login response code: ", response_code)
	print("Login response body: ", body.get_string_from_utf8())
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		print("Parsed response: ", response)
		if response and response.has("user_id"):
			Global.player_user_id = response["user_id"]
			Global.player_name = response.get("name", "")
			Global.player_email = response.get("email", "")
			Global.player_profile_pic = response.get("profile_pic", "")
			error_label.text = "Login successful!"
			visible = false
			get_parent().main_buttons.visible = true
			PlayerStats.load_stats_from_server(Global.player_user_id)
			
			# --- Show AccountPanel after login ---
			var account_panel = get_parent().get_node("AccountPanel")
			account_panel.visible = true
			account_panel.show_account_details()
		else:
			error_label.text = "Invalid login."
	else:
		error_label.text = "Login failed."
