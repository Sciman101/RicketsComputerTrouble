extends Node2D

@onready var master_bus := AudioServer.get_bus_index("Master")
@onready var window := get_window()

func _ready():
	$Settings/MarginContainer/List/VolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))

func _on_1x_pressed():
	window.size = Vector2i(1280,720)
	window.mode = Window.MODE_WINDOWED

func _on_fullscreen_pressed():
	window.size = Vector2i(1280,720)
	window.mode = Window.MODE_FULLSCREEN

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func _on_play_button_pressed():
	RoomManager.goto("res://intro.tscn","",false,false)
