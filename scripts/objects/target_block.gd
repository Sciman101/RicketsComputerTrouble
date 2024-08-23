extends StaticBody2D

const FeatherBurst = preload("res://partial/effects/feather_burst.tscn")

func on_shot(_motion):
	var burst = Utils.spawn(FeatherBurst, global_position + Vector2(16,16), get_parent())
	burst.direction = _motion.normalized()
	burst.one_shot = true
	burst.finished.connect(burst.queue_free)
	queue_free()
