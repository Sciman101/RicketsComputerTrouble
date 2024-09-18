extends Area2D

@onready var sprite = $AnimatedSprite2D

@export var spriteframes : SpriteFrames
@export var offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	if name == 'Buddy':
		push_error("Forgot to rename buddy!")
	sprite.offset = offset
	sprite.sprite_frames = spriteframes
	if Stats.buddy_has_been_visited(name):
		sprite.play("visited")
	else:
		sprite.play('default')

func _on_body_entered(body):
	if not Stats.buddy_has_been_visited(name) and $Timer.is_stopped():
		sprite.play("visited")
		SoundManager.play('children-cheering')
		Ui.show_popup("You found a buddy!")
		Stats.visit_buddy(name)
