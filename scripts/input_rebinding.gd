extends CanvasLayer

const FILE = "user://keyboard_rebindings.json"

const ACTION_NAMES = [
	&"left",
	&"right",
	&"down",
	&"up",
	&"jump",
	&"shoot",
	&"restart"
]
@onready var action_buttons = {
	left=$MarginContainer/Panel/VBoxContainer/InputButtonLeft/Button,
	right=$MarginContainer/Panel/VBoxContainer/InputButtonRight/Button,
	up=$MarginContainer/Panel/VBoxContainer/InputButtonUp/Button,
	down=$MarginContainer/Panel/VBoxContainer/InputButtonDown/Button,
	jump=$MarginContainer/Panel/VBoxContainer/InputButtonJump/Button,
	shoot=$MarginContainer/Panel/VBoxContainer/InputButtonShoot/Button,
	restart=$MarginContainer/Panel/VBoxContainer/InputButtonRestart/Button,
}
@onready var waiting_panel = $MarginContainer/WaitingPanel
@onready var waiting_panel_label = $MarginContainer/WaitingPanel/WaitingPanelLabel

var default_actions = {}

var is_waiting_for_input : bool = false
var action_to_remap : StringName

func _ready():
	
	# Save defaults
	for action in ACTION_NAMES:
		default_actions[action] = InputMap.action_get_events(action).back()
	
	# Try and load events
	if FileAccess.file_exists(FILE):
		var text = FileAccess.get_file_as_string(FILE)
		var dict = JSON.parse_string(text)
		if dict != null:
			for action in ACTION_NAMES:
				var keycode = dict.get(action)
				if keycode != KEY_NONE:
					var ev = InputEventKey.new()
					ev.keycode = keycode
					rebind_action(action, ev)
	
	# Autoload actions
	for action in ACTION_NAMES:
		var button = action_buttons[action.to_lower()]
		button.pressed.connect(listen_for_new_event.bind(action))
		update_action_button_label(action)

func listen_for_new_event(action:StringName):
	action_to_remap = action
	is_waiting_for_input = true
	waiting_panel_label.text = "Press key for '" + action + '"'
	waiting_panel.show()

func update_action_button_label(action:StringName, event:InputEvent=null):
	var button = action_buttons[action.to_lower()]
	if event == null:
		event = InputMap.action_get_events(action).back()
	button.text = event.as_text()

func stop_listening_for_input():
	is_waiting_for_input = false
	waiting_panel.hide()

func rebind_action(action, new_event):
	var original_event = InputMap.action_get_events(action).back()
	InputMap.action_erase_event(action, original_event)
	InputMap.action_add_event(action, new_event)

func _input(event):
	if is_waiting_for_input:
		# Only listen for keyboard stuff
		if event is InputEventKey:
			var key = event.keycode
			if key == Key.KEY_ESCAPE:
				stop_listening_for_input()
			else:
				rebind_action(action_to_remap, event)
				update_action_button_label(action_to_remap, event)
				stop_listening_for_input()

func close():
	hide()
	print('saving new keyboard inputs')
	var key_file = FileAccess.open(FILE, FileAccess.WRITE)
	var dict = {}
	for action in ACTION_NAMES:
		var event = InputMap.action_get_events(action).back()
		if event is InputEventKey:
			var keycode = event.keycode
			dict[action] = keycode
	key_file.store_string(JSON.stringify(dict))

func _on_reset_inputs_pressed():
	# Erase old stuff
	FileAccess.open(FILE, FileAccess.WRITE)
	for action in ACTION_NAMES:
		rebind_action(action, default_actions[action])
		update_action_button_label(action)
