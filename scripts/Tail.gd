extends Line2D

const TAIL_SEGMENT_DISTANCE := 12.0

var tail_segment_positions = []
var rest_y = []

func _ready():
	# Setup points array
	for point in points:
		tail_segment_positions.append(point + global_position)
		rest_y.append(point.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for i in get_point_count():
		# The root point is always stuck to ricket's butt
		if i == 0:
			tail_segment_positions[i] = global_position
			continue
		
		var prev_point = tail_segment_positions[i - 1]
		var point = tail_segment_positions[i]
		var dist = prev_point.distance_to(point)
		if dist > TAIL_SEGMENT_DISTANCE:
			var new_point = prev_point + (point - prev_point).normalized() * TAIL_SEGMENT_DISTANCE
			tail_segment_positions[i] = new_point
		
		set_point_position(i, tail_segment_positions[i] - global_position)
