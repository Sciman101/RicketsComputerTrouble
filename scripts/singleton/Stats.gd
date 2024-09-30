extends Node

var visited_buddies = {}

var shots := 0
var deaths := 0
var laptops := 0
var laptops_total := 83
var buddies := 0
var buddies_total := 5

func buddy_has_been_visited(buddy_name):
	return visited_buddies.get(buddy_name, false)

func visit_buddy(buddy_name):
	if not buddy_has_been_visited(buddy_name):
		buddies += 1
		visited_buddies[buddy_name] = true

func calculate_completion():
	var laptops_percent = laptops / max(laptops_total,1)
	var buddies_percent = buddies / buddies_total
	var percent= laptops_percent * 0.8 + buddies_percent * 0.2
	return round(percent* 100)

func _input(e):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		get_window().mode = Window.MODE_FULLSCREEN if get_window().mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED
