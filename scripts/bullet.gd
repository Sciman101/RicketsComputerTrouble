extends Area2D

const LIFETIME := 30.0

var motion : Vector2
var lifetime = LIFETIME

@onready var sprite = $BulletSprite

func _physics_process(delta):
	position += motion * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("TargetBlock"):
		# Disable target blocks
		body.queue_free()
	destroy_bullet()

func _on_area_entered(area):
	if area.is_in_group("Laptop") and area.active:
		destroy_bullet()
		area.on_shot()

func destroy_bullet():
	sprite.play("default")
	set_deferred("monitoring", false)
	motion = Vector2.ZERO

func _on_bullet_sprite_animation_finished():
	queue_free()
