extends Area2D

@export var linked_door_name : String
@export_file("*.tscn", "*.scn") var scene_to_load
@export var default_spawn : bool = false

@onready var sprite = $Sprite

var overlapping : bool
var has_connected_door : bool = true

func _ready():
	sprite.frame = 0
	set_process_unhandled_input(true)
	if not scene_to_load:
		modulate = Color.GRAY
		has_connected_door = false

func _on_body_entered(body):
	if body.is_in_group("Player"):
		overlapping = true
		if has_connected_door:
			sprite.play("open")

func _on_body_exited(body):
	if body.is_in_group("Player"):
		overlapping = false
		if has_connected_door:
			sprite.play("close")

func _unhandled_input(event):
	if overlapping:
		if Input.is_action_just_pressed("up") and not RoomManager.is_transitioning:
			if has_connected_door:
				RoomManager.goto(scene_to_load, linked_door_name)
