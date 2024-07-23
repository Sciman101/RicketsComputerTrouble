extends Control

const DARK := Color(0,0,0,0.5)

@onready var shell_graphics = get_children()

func set_amount(amount:int, animate:bool=false):
	for i in 3:
		var shell = shell_graphics[i]
		var active = (amount-1) >= i
		shell.modulate = Color.WHITE if active else DARK
