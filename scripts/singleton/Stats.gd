extends Node

var visited_buddies = {}

var deaths := 0
var laptops := 0
var laptops_total := 0
var buddies := 0

func buddy_has_been_visited(buddy_name):
	return visited_buddies.get(buddy_name, false)

func visit_buddy(buddy_name):
	if not buddy_has_been_visited(buddy_name):
		buddies += 1
		visited_buddies[buddy_name] = true
