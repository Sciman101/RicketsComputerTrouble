extends Area2D

@export var help_text : String

var text_to_show : String

func _ready():
	var index = 0
	while index < help_text.length():
		var c = help_text.substr(index,1)
		if c == '[':
			var closing_index = index
			while c != ']':
				c = help_text.substr(closing_index, 1)
				closing_index += 1
				if closing_index > help_text.length():
					push_error("No closing bracket for input event parse!")
			var action_name = help_text.substr(index+1,closing_index-index-2)
			text_to_show += Utils.get_keyboard_event_text(action_name)
			index = closing_index - 1
		else:
			text_to_show += c
		index += 1

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Ui.show_popup(text_to_show)
