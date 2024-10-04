extends Node

const NUM_PLAYERS := 10

const Samples = {
	'shotgun-bounce': preload("res://sfx/shotgun_bounce.wav"),
	'shotgun-fire': preload("res://sfx/shotgun_fire.wav"),
	'shotgun-reload': preload("res://sfx/shotgun_reload.wav"),
	'tick': preload("res://sfx/tick.wav"),
	'ding': preload("res://sfx/611113__5ro4__bell-ding-1.wav"),
	'bullet-impact': [preload("res://sfx/bullet_impact-01.wav"),preload("res://sfx/bullet_impact-02.wav"),preload("res://sfx/bullet_impact-03.wav")],
	'shell-bounce': [preload("res://sfx/shell_fall-02.wav"),preload("res://sfx/shell_fall-01.wav"),preload("res://sfx/shell_fall-03.wav")],
	'laptop-destroy': [preload("res://sfx/laptop-destroy-1.wav")],
	'children-cheering': preload("res://sfx/children_cheering.wav"),
	'death': preload("res://sfx/death.wav"),
}


func _ready():
	for i in NUM_PLAYERS:
		var player = AudioStreamPlayer.new()
		add_child(player)

func _get_available_player():
	for child in get_children():
		if not child.playing:
			return child
	return null

func play(id:String, pitch: float = 1, volume_linear: float = 1, pitch_random : float = 0, volume_linear_random : float = 0, bus:String="SFX"):
	var sample = Samples.get(id)
	if sample == null:
		push_error("Trying to play unknown sample ", id)
		return
	elif sample is Array:
		sample = sample.pick_random()
	var player = _get_available_player()
	if not player:
		push_warning("No available AudioStreamPlayers to play ", id)
		return
	player.stream = sample
	player.bus = bus
	player.pitch_scale = pitch + randf_range(-pitch_random, pitch_random)
	player.volume_db = linear_to_db(volume_linear + randf_range(-volume_linear_random, volume_linear_random))
	player.play()
