extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Player.position = $PlayerStart.position
	Player.set_has_shotgun(false)
