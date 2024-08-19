extends StaticBody2D

@onready var graphic = $ProgressGraphic

@export var duration := 5.0

var time_left : float = 0.0
var current_duration : float
var running = false
var shot = false
var last_sound_time : float = 0.0

var sprite_velocity : Vector2

signal toggle_blocks

# Start the timer
func on_shot(motion):
	for timer in get_tree().get_nodes_in_group("Stopwatch"):
		timer.shot = timer == self
		timer.start_timer(duration)
	sprite_velocity = motion * .1

func on_bounce(player):
	sprite_velocity -= player.global_position - global_position
	# start_timer()

func start_timer(_duration:float):
	if not running:
		if shot:
			toggle_blocks.emit()
		running = true
	current_duration = _duration
	time_left = _duration
	last_sound_time = duration
	if shot:
		SoundManager.play('tick')

func stop_timer():
	graphic.value = 0
	running = false
	time_left = 0
	sprite_velocity = Vector2.UP * 100
	if shot:
		toggle_blocks.emit()
		SoundManager.play('ding',1,0.2)

func _process(delta):
	if running:
		time_left -= delta
		if time_left <= 0:
			stop_timer()
		else:
			play_sound()
			graphic.value = (time_left / current_duration)
	
	sprite_velocity = Utils.spring(graphic.position, Vector2(-32,-32), sprite_velocity, 10, 0.85)
	graphic.position += sprite_velocity * delta

func play_sound():
	if shot:
		var interval = 1
		if time_left < 3: interval = 0.5
		if time_left < 2: interval = 0.25
		if time_left <= last_sound_time - interval:
			last_sound_time = time_left
			var pitch = (floori(time_left / interval) % 2) * 0.2 + 1
			SoundManager.play('tick', pitch)
