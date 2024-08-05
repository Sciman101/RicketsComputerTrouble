extends Node2D

@export var popup_text : String

func _ready():
	if popup_text.length() > 0:
		Ui.show_popup(popup_text)
