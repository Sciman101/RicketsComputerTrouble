extends CanvasLayer

const FADE_DURATION := 0.25
const TRANSPARENT := Color(0,0,0,0)

@onready var fade_rect = $Fade

var target_scene_path : String # Scene to load
var linked_door_name : String # Door to go to

var is_transitioning : bool = false

# Reference to the current scene
var current_scene

# Are these laptops destroyed?
var laptops = {}
var seen_laptops = {}

signal scene_changed

func _ready():
	current_scene = get_tree().current_scene
	scene_changed.emit()

func load_scene(path:String):
	var tree = get_tree()
	# Remove current level
	tree.root.remove_child(current_scene)
	current_scene.call_deferred('queue_free')
	
	current_scene = load(path).instantiate()
	tree.root.add_child(current_scene)
	
	scene_changed.emit()

# Load a scene and optionally provide a door to warp to
func goto(scene_to_load:String, linked_door_name:String="", hide_player:bool = false, animate_fade:bool=true):
	target_scene_path = scene_to_load
	self.linked_door_name = linked_door_name
	if animate_fade:
		var tween = get_tree().create_tween()
		fade_rect.modulate = TRANSPARENT
		Player.set_physics_process(false)
		is_transitioning = true
		tween.tween_property(fade_rect, 'modulate', Color.BLACK, FADE_DURATION)
		tween.tween_callback(_do_scene_transition)
		tween.tween_property(fade_rect, 'modulate', Color.TRANSPARENT, FADE_DURATION)
		await tween.finished
		is_transitioning = false
	else:
		_do_scene_transition()
	Ui.hide_popup()
	if hide_player:
		Player.hide()
	else:
		Player.show()
		Player.set_physics_process(true)

# Called in between the transition tween to actually change the scene
func _do_scene_transition():
	load_scene(target_scene_path)
	var door = find_door_by_name(self.linked_door_name)
	if door:
		Player.warp_to_door(door)

# Find a door by its name
func find_door_by_name(door_name:String):
	var doors = get_tree().get_nodes_in_group("Door")
	for door in doors:
		if door.name == door_name:
			return door
	return null
