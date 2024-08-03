extends Camera2D

@export var path : Path2D

var screenshake_amount : float
var screenshake_duration : float

var curve : Curve2D

func _ready():
	Utils.camera = self
	set_path(path)

func add_screenshake(amount:float=4,duration:float=0.075):
	screenshake_amount = amount
	screenshake_duration += duration

func kick(amount:Vector2):
	offset += amount

func set_path(path:Path2D):
	if path:
		curve = path.curve
		position_smoothing_enabled = false
		position = curve.get_closest_point(Player.position)
		await get_tree().create_timer(0.1).timeout
		position_smoothing_enabled = true

func _process(delta):
	if curve:
		position = curve.get_closest_point(Player.position)
	
	if screenshake_duration > 0:
		screenshake_duration -= delta
		offset.x = randi_range(-screenshake_amount, screenshake_amount)
		offset.y = randi_range(-screenshake_amount, screenshake_amount)
	else:
		offset = lerp(offset, Vector2.ZERO, delta * 10)
