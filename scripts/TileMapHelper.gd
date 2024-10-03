extends TileMap

var overlay_layer_index : int
var background_layer_index : int
var platform_layer_index : int
var overlay_layer_hidden : bool = true

var used_rect : Rect2i

func _ready():
	for i in get_layers_count():
		var n = get_layer_name(i)
		if n == "Overlay":
			overlay_layer_index = i
		if n == "Background":
			background_layer_index = i
		if n == "Platforms":
			platform_layer_index = i
	# Just in case we disabled it for debuggin
	set_layer_enabled(overlay_layer_index, true)
	set_layer_enabled(background_layer_index, true)
	
	used_rect = get_used_rect()
	
	RoomManager.scene_changed.connect(self.check_reveal_overlay)
	
	for node in get_tree().get_nodes_in_group("Stopwatch"):
		node.toggle_blocks.connect(self.toggle_stopwatch_blocks)

func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	return layer == overlay_layer_index or layer == background_layer_index

func _tile_data_runtime_update(layer: int, coords: Vector2i, tile_data: TileData) -> void:
	# For the overlay layer, turn off any collisions
	tile_data.set_collision_polygons_count(0, 0)

func check_reveal_overlay():
	if RoomManager.linked_door_name == "Exit":
		await get_tree().process_frame
		# We do this so players going back through a room don't need t
		reveal_overlay_layer(null)

func reveal_overlay_layer(body):
	if overlay_layer_hidden:
		overlay_layer_hidden = false
		var tween = get_tree().create_tween()
		tween.tween_method(set_overlay_layer_modulate,Color.WHITE,Color.TRANSPARENT,0.5)

func set_overlay_layer_modulate(mod:Color):
	set_layer_modulate(overlay_layer_index, mod)

func toggle_stopwatch_blocks():
	for x in range(used_rect.position.x, used_rect.position.x+used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.x+used_rect.size.y):
			var pos = Vector2i(x,y)
			var dat = get_cell_atlas_coords(platform_layer_index, pos)
			# Stopwatch blocks. Yes, it sucks to do it this way
			if dat.x == 10 and dat.y <= 1:
				set_cell(platform_layer_index, pos, 0, Vector2(10, 1-dat.y))
