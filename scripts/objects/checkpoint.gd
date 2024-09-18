extends Area2D

func _on_body_entered(body):
	body.mark_checkpoint(self)
	$AnimatedSprite2D.play('visited')
