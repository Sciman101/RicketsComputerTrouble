extends Area2D

@onready var DebrisArray = [preload("res://partial/effects/laptop_debris_1.tscn"),preload("res://partial/effects/laptop_debris_2.tscn"),preload("res://partial/effects/laptop_debris_3.tscn")]
@onready var Explosion = preload("res://partial/effects/explosion.tscn")

var active : bool = true

signal on_destroyed

func _ready():
	# We use the absolute path of the laptop as a sort of uuid
	# As long as rooms are named uniquely, this should work
	active = RoomManager.laptops.get(get_path(), true)
	if not active:
		modulate = Color(0,0,0,0.5)

func on_shot():
	if active:
		active = false
		Utils.camera.add_screenshake()
		Stats.laptops += 1
		RoomManager.laptops[get_path()] = false
		
		# Make debris
		for i in 3:
			var force = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(500,1000)
			var debris = Utils.spawn(DebrisArray[i], global_position, RoomManager.current_scene)
			debris.apply_force(force)
			debris.apply_torque(randf_range(-100,100))
		Utils.spawn(Explosion, global_position, RoomManager.current_scene)
		
		SoundManager.play('laptop-destroy',1,0.4,0.5)
		
		on_destroyed.emit()
		
		queue_free()
