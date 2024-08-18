extends Area2D

@export var linked_door_name : String
@export_file("*.tscn", "*.scn") var scene_to_load
@export var default_spawn : bool = false

var overlapping : bool

func _ready():
	set_process_unhandled_input(true)
	if linked_door_name.length() == 0:
		modulate = Color.GRAY

func _on_body_entered(body):
	if body.is_in_group("Player"):
		overlapping = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		overlapping = false

func _unhandled_input(event):
	if overlapping:
		if Input.is_action_just_pressed("up") and not RoomManager.is_transitioning:
			if scene_to_load:
				RoomManager.goto(scene_to_load, linked_door_name)
