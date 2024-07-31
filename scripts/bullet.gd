extends Area2D

const LIFETIME := 30.0

var motion : Vector2
var lifetime = LIFETIME

func _physics_process(delta):
	position += motion * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("TargetBlock"):
		# Disable target blocks
		body.queue_free()
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("Laptop") and area.active:
		queue_free()
		area.on_shot()
