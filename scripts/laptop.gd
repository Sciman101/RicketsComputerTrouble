extends Area2D

var active : bool = true

func _ready():
	# We use the absolute path of the laptop as a sort of uuid
	# As long as rooms are named uniquely, this should work
	active = RoomManager.laptops.get(get_path(), true)
	if not active:
		modulate = Color(0,0,0,0.5)

func on_shot():
	Utils.camera.add_screenshake()
	Stats.laptops += 1 
	RoomManager.laptops[get_path()] = false
	queue_free()
