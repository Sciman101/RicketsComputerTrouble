extends Node

var visited_buddies = {}

var shots := 0
var deaths := 0
var laptops := 0
var laptops_total := 84
var buddies := 0
var buddies_total := 5

func reset():
	visited_buddies = {}
	shots = 0
	laptops = 0
	deaths = 0
	buddies = 0

func buddy_has_been_visited(buddy_name):
	return visited_buddies.get(buddy_name, false)

func visit_buddy(buddy_name):
	if not buddy_has_been_visited(buddy_name):
		buddies += 1
		visited_buddies[buddy_name] = true

func calculate_completion():
	var laptops_percent = float(laptops) / max(laptops_total,1)
	var buddies_percent = float(buddies) / buddies_total
	var percent= laptops_percent * 0.8 + buddies_percent * 0.2
	return round(percent* 100)
