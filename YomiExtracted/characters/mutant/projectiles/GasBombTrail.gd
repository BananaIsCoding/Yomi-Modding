extends Node2D





const TRAIL_LENGTH = 30
const COLOR = Color("64d26b")

var target = null
var positions = []

func tick():
	var alive = is_instance_valid(target) and not target.disabled
	if alive:
		positions.append(target.get_pos_visual())
		while positions.size() > TRAIL_LENGTH:
			positions.pop_front()
	else:
		
		
		if positions.size() > 0:
			positions.pop_front()
		if positions.empty():
			queue_free()
			return
	update()

func _draw():
	if positions.size() < 2:
		return
	var n = positions.size()
	var origin = global_position
	for i in range(n - 1):
		
		
		var c = COLOR
		c.a = float(i + 1) / float(n)
		draw_line(positions[i] - origin, positions[i + 1] - origin, c, 1.0)
