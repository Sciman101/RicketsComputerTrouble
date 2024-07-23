extends Sprite2D

var gravity : float

var velocity : Vector2
var angular_velocity : float

func _process(delta):
	position += velocity * delta
	velocity.y += gravity * delta
	rotation += angular_velocity * delta
