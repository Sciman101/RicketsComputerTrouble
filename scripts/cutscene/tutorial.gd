extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Player.position = $PlayerStart.position
	$PlayerStart.hide()
	Player.set_has_shotgun(false)
	Player.enable()
	Ui.show()
	
	tutorial_sequence()

func tutorial_sequence():
	await Utils.wait_sec(1)
	
	Ui.show_popup("%s/%s, or Left Stick to move" % [Utils.get_keyboard_event_text(&"left"),Utils.get_keyboard_event_text(&"right")], 0)
	await Player.on_move
	Stats.timer_running = true
	
	await Ui.hide_popup()
	Ui.show_popup("%s key or A button to jump" % Utils.get_keyboard_event_text(&"jump"), 0)
	await Player.on_jump
	
	await Ui.hide_popup()
	if Player.super_duper_shotgun:
		Ui.show_popup("Get your super-duper shotgun from under the bed", 0)
	else:
		Ui.show_popup("Get your laptop repair tool from under the bed", 0)
	
	await $ShotgunPickup.body_entered
	Player.set_has_shotgun(true)
	SoundManager.play('shotgun-reload')
	
	await Ui.hide_popup()
	Ui.show_popup("Fix the laptop (%s key/X button/Right Trigger to shoot)" % Utils.get_keyboard_event_text(&"shoot"), 0)
	
	await $Laptop.on_destroyed
	
	await Ui.hide_popup()
	$FalseFloor.position.x -= 500
	Ui.show_popup("Leave (up to enter doors)", 0)
	
	await $FallDetector.body_entered
	$TileMap.reveal_overlay_layer(null)
	
	await Utils.wait_sec(1)
	
	RoomManager.goto("res://rooms/beginner_room.tscn", "Start")
