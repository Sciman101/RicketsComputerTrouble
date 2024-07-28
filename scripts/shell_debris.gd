extends RigidBody2D

const MIN_SOUND_DELAY := 200

var last_sound_time := 0.0

func _on_body_entered(body):
	if linear_velocity.length_squared() > MIN_SOUND_DELAY:
		var time = Time.get_ticks_msec()
		if time > last_sound_time + MIN_SOUND_DELAY:
			last_sound_time = time
			var power = min(linear_velocity.length() / 1000,1)
			SoundManager.play('shell-bounce', lerp(1.5,1.0,power), power)
