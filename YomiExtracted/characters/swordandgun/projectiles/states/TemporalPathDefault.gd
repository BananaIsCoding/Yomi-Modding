extends ObjectState
















var _swept_hitboxes = []



const HITBOX_HALF = 4

func _enter():
	
	
	host.set_facing(1)
	_swept_hitboxes = []
	for child in get_children():
		if child is SweptHitbox:
			_swept_hitboxes.append(child)

func _tick():
	
	var fighter = host.get_fighter()
	if fighter and fighter.is_in_hurt_state(false):
		host.disable()
		return
	if current_tick == 0:
		
		var di = fighter.current_di if fighter else null
		if di != null:
			host.di_x = str(di.x)
			host.di_y = str(di.y)
	var delay = host.delay_fast if host.fast else host.delay_normal
	var active_end = delay + host.active_frames
	var fade_end = active_end + host.fade_frames
	
	if current_tick >= fade_end:
		host.disable()
		return
	
	
	
	var live = current_tick >= delay and current_tick < active_end
	host.activated = current_tick >= delay
	if current_tick < delay:
		host.line_width = host.LINE_WIDTH_GREY
	elif current_tick < active_end:
		host.line_width = host.LINE_WIDTH_PURPLE
	else:
		var f = float(current_tick - active_end) / float(host.fade_frames)
		host.line_width = host.LINE_WIDTH_PURPLE * (1.0 - f)
	
	_compute_path()
	_configure_hitboxes(live)
	host.update()



func _compute_path():
	var di_dir = fixed.normalized_vec(host.di_x, host.di_y)
	var has_di = not fixed.eq(fixed.vec_len(di_dir.x, di_dir.y), "0")

	
	
	var box = _after_image_box() if has_di else null

	
	
	
	var start = host.get_pos()
	var sx = start.x
	var sy = start.y
	if sx > host.stage_width - 1:
		sx = host.stage_width - 1
	elif sx < 1 - host.stage_width:
		sx = 1 - host.stage_width
	if sy > - 1:
		sy = - 1
	if host.has_ceiling and sy < 1 - host.ceiling_height:
		sy = 1 - host.ceiling_height
	var px = str(sx)
	var py = str(sy)
	var dx = host.dir_x
	var dy = host.dir_y

	host.path_x = [sx]
	host.path_y = [sy]

	
	
	var num_segments = int(max(1, host.ricochet_count + 1))
	num_segments = int(min(num_segments, _swept_hitboxes.size()))

	
	
	var last_surface = ""

	for i in range(num_segments):
		var hit = _raycast(px, py, dx, dy, box, last_surface)
		host.path_x.append(fixed.round(hit.x))
		host.path_y.append(fixed.round(hit.y))
		
		if hit.capped or i == num_segments - 1:
			break
		last_surface = hit.surface
		var in_dx = dx
		var in_dy = dy
		if hit.surface == "afterimage":
			
			
			
			if has_di:
				dx = di_dir.x
				dy = di_dir.y
		else:
			
			if has_di:
				dx = di_dir.x
				dy = di_dir.y
			else:
				
				if hit.axis == "x":
					dx = fixed.mul(in_dx, "-1")
				else:
					dy = fixed.mul(in_dy, "-1")
			
			
			
			
			
			if hit.axis == "x":
				if _same_sign(dx, in_dx):
					dx = fixed.mul(dx, "-1")
				if _opposite_sign(dy, in_dy):
					dy = fixed.mul(dy, "-1")
			else:
				if _same_sign(dy, in_dy):
					dy = fixed.mul(dy, "-1")
				if _opposite_sign(dx, in_dx):
					dx = fixed.mul(dx, "-1")
		var n = fixed.normalized_vec(dx, dy)
		dx = n.x
		dy = n.y
		px = hit.x
		py = hit.y

func _same_sign(a, b):
	return (fixed.gt(a, "0") and fixed.gt(b, "0")) or (fixed.lt(a, "0") and fixed.lt(b, "0"))

func _opposite_sign(a, b):
	return (fixed.gt(a, "0") and fixed.lt(b, "0")) or (fixed.lt(a, "0") and fixed.gt(b, "0"))





func _raycast(px, py, dx, dy, box, exclude):
	var best_t = null
	var best_axis = ""
	var best_surface = ""
	if not fixed.eq(dx, "0"):
		var going_right = fixed.gt(dx, "0")
		var surface = "wall+" if going_right else "wall-"
		if surface != exclude:
			var wall = host.stage_width if going_right else - host.stage_width
			var t = fixed.div(fixed.sub(str(wall), px), dx)
			if fixed.gt(t, "0"):
				best_t = t
				best_axis = "x"
				best_surface = surface
	if fixed.gt(dy, "0") and exclude != "floor":
		var t = fixed.div(fixed.sub("0", py), dy)
		if fixed.gt(t, "0") and (best_t == null or fixed.lt(t, best_t)):
			best_t = t
			best_axis = "y"
			best_surface = "floor"
	if fixed.lt(dy, "0") and host.has_ceiling and exclude != "ceiling":
		var t = fixed.div(fixed.sub(str( - host.ceiling_height), py), dy)
		if fixed.gt(t, "0") and (best_t == null or fixed.lt(t, best_t)):
			best_t = t
			best_axis = "y"
			best_surface = "ceiling"
	
	
	
	if box != null and exclude != "afterimage" and not fixed.eq(dx, "0") and not fixed.eq(dy, "0"):
		var b = _ray_box(px, py, dx, dy, box)
		if b != null and (best_t == null or fixed.lt(b.t, best_t)):
			best_t = b.t
			best_axis = b.axis
			best_surface = "afterimage"
	var capped = false
	if best_t == null or fixed.gt(best_t, str(host.segment_cap)):
		best_t = str(host.segment_cap)
		capped = true
	return {
		"x": fixed.add(px, fixed.mul(dx, best_t)), 
		"y": fixed.add(py, fixed.mul(dy, best_t)), 
		"axis": best_axis, 
		"surface": best_surface, 
		"capped": capped, 
	}



func _ray_box(px, py, dx, dy, box):
	var tx1 = fixed.div(fixed.sub(str(box.x1), px), dx)
	var tx2 = fixed.div(fixed.sub(str(box.x2), px), dx)
	var tminx = _fmin(tx1, tx2)
	var tmaxx = _fmax(tx1, tx2)
	var ty1 = fixed.div(fixed.sub(str(box.y1), py), dy)
	var ty2 = fixed.div(fixed.sub(str(box.y2), py), dy)
	var tminy = _fmin(ty1, ty2)
	var tmaxy = _fmax(ty1, ty2)
	var tenter = _fmax(tminx, tminy)
	var texit = _fmin(tmaxx, tmaxy)
	if fixed.gt(tenter, texit) or fixed.le(tenter, "0"):
		return null
	return {"t": tenter, "axis": "x" if fixed.gt(tminx, tminy) else "y"}

func _fmin(a, b):
	return a if fixed.lt(a, b) else b

func _fmax(a, b):
	return a if fixed.gt(a, b) else b


func _after_image_box():
	var fighter = host.get_fighter()
	if fighter == null:
		return null
	var ai_name = fighter.get("after_image_object")
	if not ai_name:
		return null
	var ai = fighter.obj_from_name(ai_name)
	if ai == null or ai.disabled:
		return null
	var c = ai.get_hurtbox_center()
	var hw = ai.hurtbox.width
	var hh = ai.hurtbox.height
	return {
		"x1": c.x - hw, "x2": c.x + hw, 
		"y1": c.y - hh, "y2": c.y + hh, 
	}



func _configure_hitboxes(live):
	
	
	
	var hp = host.get_pos()
	var num_segments = host.path_x.size() - 1
	
	
	var path_changed = false
	for i in range(_swept_hitboxes.size()):
		var h = _swept_hitboxes[i]
		if i < num_segments:
			var nx = host.path_x[i] - hp.x
			var ny = host.path_y[i] - hp.y
			var ntx = host.path_x[i + 1] - host.path_x[i]
			var nty = host.path_y[i + 1] - host.path_y[i]
			if h.active and (h.x != nx or h.y != ny or h.to_x != ntx or h.to_y != nty):
				path_changed = true
			
			h.width = HITBOX_HALF
			h.height = HITBOX_HALF
			h.x = nx
			h.y = ny
			h.to_x = ntx
			h.to_y = nty
			
			
			h.priority = _swept_hitboxes.size() - i
			var seg = fixed.normalized_vec(str(h.to_x), str(h.to_y))
			h.dir_x = seg.x
			h.dir_y = seg.y
			
			
			if live and not h.active:
				h.activate()
			elif not live and h.active:
				h.deactivate()
		else:
			
			if h.active:
				h.deactivate()
			h.width = 0
			h.height = 0
	
	
	
	if path_changed:
		for h in _swept_hitboxes:
			if h.active:
				h.reset_hit_objects()
				break
