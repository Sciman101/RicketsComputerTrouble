extends TileMap

var overlay_layer_index : int
var background_layer_index : int
var overlay_layer_hidden : bool = true

func _ready():
	for i in get_layers_count():
		var n = get_layer_name(i)
		if n == "Overlay":
			overlay_layer_index = i
		if n == "Background":
			background_layer_index = i
	# Just in case we disabled it for debuggin
	set_layer_enabled(overlay_layer_index, true)
	set_layer_enabled(background_layer_index, true)

func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	return layer == overlay_layer_index or layer == background_layer_index

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
