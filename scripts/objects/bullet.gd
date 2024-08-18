extends Area2D

const LIFETIME := 30.0

var motion : Vector2
var lifetime = LIFETIME

@onready var sprite = $BulletSprite
@onready var blast_radius = $BlastRadius

func _physics_process(delta):
	position += motion * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.has_method('on_shot'):
		# Trigger action
		body.on_shot(motion)
	destroy_bullet()
	SoundManager.play('bullet-impact', 0.8, 0.2, 0.1)

func _on_area_entered(area):
	if area.is_in_group("Laptop") and area.active:
		destroy_bullet()
		area.on_shot()

func destroy_bullet():
	sprite.play("default")
	set_deferred("monitoring", false)
	motion = Vector2.ZERO
	# Explode debris
	var bodies = blast_radius.get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody2D:
			var delta = body.position - position
			body.apply_force(delta.normalized() * 1000)

func _on_bullet_sprite_animation_finished():
	queue_free()
