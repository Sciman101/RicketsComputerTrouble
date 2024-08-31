extends Area2D

const DARKENED := Color(0,0,0,0.5)

@onready var sprite = $Sprite2D
@onready var timer = $ResupplyTimer

var active := true

func _ready():
	Player.on_respawn.connect(self._on_resupply_timer_timeout)

func _on_resupply_timer_timeout():
	active = true
	timer.stop()
	modulate = Color.WHITE

func _on_body_entered(body):
	if active and body.is_in_group("Player"):
		active = false
		body.get_shell()
		modulate = DARKENED
		timer.start()
