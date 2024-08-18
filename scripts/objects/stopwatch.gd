extends StaticBody2D

@onready var sprite = $Sprite2D

@export var duration := 5.0

var time_left : float = 0.0
var running = false
var last_sound_time : float = 0.0

var sprite_velocity : Vector2

signal toggle_blocks

# Start the timer
func on_shot(motion):
	start_timer()
	sprite_velocity = motion * .1

func on_bounce(player):
	sprite_velocity -= player.global_position - global_position
	start_timer()

func start_timer():
	if not running:
		toggle_blocks.emit()
		running = true
	time_left = duration
	last_sound_time = duration
	SoundManager.play('tick')

func stop_timer():
	sprite.frame = 0
	running = false
	time_left = 0
	toggle_blocks.emit()

func _process(delta):
	if running:
		time_left -= delta
		if time_left <= 0:
			stop_timer()
		else:
			play_sound()
			sprite.frame = floor((time_left / duration) * (sprite.hframes - 1))  + 1
	
	sprite_velocity = Utils.spring(sprite.offset, Vector2.ZERO, sprite_velocity, 10, 0.85)
	sprite.offset += sprite_velocity * delta

func play_sound():
	var interval = 1
	if time_left < 3: interval = 0.5
	if time_left < 2: interval = 0.25
	if time_left <= last_sound_time - interval:
		last_sound_time = time_left
		var pitch = (floori(time_left / interval) % 2) * 0.2 + 1
		SoundManager.play('tick', pitch)
