extends TileMap

var overlay_layer_index : int
var overlay_layer_hidden : bool = true

func _ready():
	for i in get_layers_count():
		if get_layer_name(i) == "Overlay":
			overlay_layer_index = i
			break
	# Just in case we disabled it for debugging
	set_layer_enabled(overlay_layer_index, true)

func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	return layer == overlay_layer_index

func _tile_data_runtime_update(layer: int, coords: Vector2i, tile_data: TileData) -> void:
	# For the overlay layer, turn off any collisions
	tile_data.set_collision_polygons_count(0, 0)

func reveal_overlay_layer(body):
	if overlay_layer_hidden:
		overlay_layer_hidden = false
		var tween = get_tree().create_tween()
		tween.tween_method(set_overlay_layer_modulate,Color.WHITE,Color.TRANSPARENT,0.5)

func set_overlay_layer_modulate(mod:Color):
	set_layer_modulate(overlay_layer_index, mod)
