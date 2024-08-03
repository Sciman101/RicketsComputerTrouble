extends Node

var camera : Camera2D
var player : CharacterBody2D

func spring(from:Variant, to:Variant, vel:Variant, acc := 2.0, att := 0.9):
	vel += acc * (to - from)
	vel *= att
	return vel

func spawn(scene:PackedScene, at:Vector2, parent=null):
	var inst = scene.instantiate()
	inst.position = at
	if not parent:
		get_tree().root.call_deferred('add_child', inst)
	else:
		parent.call_deferred('add_child', inst)
	return inst
