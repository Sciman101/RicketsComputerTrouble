extends Area2D

@export var help_text : String

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Ui.show_popup(help_text)
