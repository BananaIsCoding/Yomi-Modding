extends ParticleEffect

class_name CustomTrailParticle

var shape = preload("res://fx/particle_round_4x4.png")
var shape_name = "circle"
var flip_shape = false
var random_flip = false


var total_amount = 16
var start_color = Color.white
var end_color = Color.white
var start_alpha = 1.0
var end_alpha = 1.0
var start_scale = 1.0
var end_scale = 1.0





var color_midpoint = 0.5
var alpha_midpoint = 0.5
var scale_midpoint = 0.5



var transform_scale_x = 1.0
var transform_scale_y = 1.0



var transform_rotation = 0.0

var default_gravity_x = 0
var facing = 1
var default_angle = 0



var no_preprocess: = false




var auto_start_on_ready: = false

onready var particles = $CPUParticles2D



var particles_flipped: CPUParticles2D = null

var custom_set = {
	"shape": "set_shape", 
	"flip_shape": "set_flip_shape", 
	"random_flip": "set_random_flip", 
	"emission_shape": "set_emission_shape", 
	"emission_circle_radius": "set_emission_circle_radius", 
	"start_color": "set_start_color", 
	"end_color": "set_end_color", 
	"start_scale": "set_start_scale", 
	"end_scale": "set_end_scale", 
	"in_front": "set_in_front", 
	"rect_size_x": "set_rect_size_x", 
	"rect_size_y": "set_rect_size_y", 
	"gravity_x": "set_gravity_x", 
	"gravity_y": "set_gravity_y", 
	"start_alpha": "set_start_alpha", 
	"end_alpha": "set_end_alpha", 
	"color_midpoint": "set_color_midpoint", 
	"alpha_midpoint": "set_alpha_midpoint", 
	"scale_midpoint": "set_scale_midpoint", 
	"transform_scale_x": "set_transform_scale_x", 
	"transform_scale_y": "set_transform_scale_y", 
	"transform_rotation": "set_transform_rotation", 
	"x_offset": "set_x_offset", 
	"y_offset": "set_y_offset", 
	"lifetime": "set_lifetime", 
	"angle": "set_angle", 
	"flip_with_character": "set_flip_with_character", 
	"framerate": "set_framerate", 
	"cap_framerate": "set_cap_framerate", 
	"custom_preprocess": "set_custom_preprocess", 
	"custom_preprocess_value": "set_custom_preprocess_value", 
	"preprocess_on_retrigger": "set_preprocess_on_retrigger", 
}

static func get_shapes():
	return {
		"circle": preload("res://fx/particle_round_4x4.png"), 
		"ellipse": preload("res://fx/ellipse.png"), 
		"square": preload("res://fx/particle_square_4x4.png"), 
		"triangle": preload("res://fx/TriUp.png"), 
		"star": preload("res://fx/star.png"), 
		"heart": preload("res://fx/heart.png"), 
		"arrow": preload("res://fx/arrow.png"), 
		"cross": preload("res://fx/cross.png"), 
		"line": preload("res://fx/line.png"), 
		"diamond": preload("res://fx/diamond.png"), 
		"shine": preload("res://fx/four_point_star.png"), 
		"shine2": preload("res://fx/shine2.png"), 
		"elec": preload("res://fx/elec.png"), 
		"hollow circle": preload("res://fx/particle_round_hollow_4x4.png"), 
		"hollow ellipse": preload("res://fx/ellipse_hollow.png"), 
		"hollow square": preload("res://fx/particle_square_hollow_4x4.png"), 
		"checkerboard 1": preload("res://fx/checkerboard_1.png"), 
		"checkerboard 2": preload("res://fx/checkerboard_2.png"), 
	}

static func get_default():
	return {
		"in_front": false, 
		"shape": "circle", 
		"flip_shape": false, 
		"random_flip": false, 
		"emission_shape": "rectangle", 
		"emission_circle_radius": 8.0, 
		"amount": 16, 
		"alpha": 1.0, 
		"local_coords": false, 
		"speed_scale": 2.0, 
		"explosiveness": 0.0, 
		"lifetime_randomness": 0.5, 
		"gravity_x": 0.0, 
		"gravity_y": 0.0, 
		"rect_size_x": 4.0, 
		"rect_size_y": 4.0, 
		"direction": Vector2(0, - 1), 
		"spread": 0.0, 
		"initial_velocity": 16.0, 
		"initial_velocity_random": 16.0, 
		"linear_accel": 0.0, 
		"linear_accel_random": 0.0, 
		"radial_accel": 0.0, 
		"radial_accel_random": 0.0, 
		"tangential_accel": 0.0, 
		"tangential_accel_random": 0.0, 
		"orbit_velocity": 0.0, 
		"orbit_velocity_random": 0.0, 
		"start_color": Color.white, 
		"end_color": Color.white, 
		"start_scale": 1.0, 
		"end_scale": 1.0, 
		"color_midpoint": 0.5, 
		"alpha_midpoint": 0.5, 
		"scale_midpoint": 0.5, 
		"transform_scale_x": 1.0, 
		"transform_scale_y": 1.0, 
		"transform_rotation": 0.0, 
		"x_offset": 0.0, 
		"y_offset": 0.0, 
		"scale_amount_random": 0.0, 
		"angle": 0.0, 
		"angle_random": 0.0, 
		"angular_velocity": 0.0, 
		"angular_velocity_random": 0.0, 
		"damping": 0.0, 
		"damping_random": 0.0, 
		"cap_framerate": false, 
		"framerate": 60, 
		"custom_preprocess": false, 
		"custom_preprocess_value": 0.0, 
		"preprocess_on_retrigger": false, 
		"disable_on_ko": true, 
		"dynamic_triggers": false, 
		"dynamic_one_shot": false, 
		"triggers_inverted": false, 
		"trigger_during_combo": false, 
		"trigger_during_combo_linger": 0, 
		"trigger_during_melee_attacks": false, 
		"trigger_during_melee_attacks_linger": 0, 
		"trigger_while_being_comboed": false, 
		"trigger_while_being_comboed_linger": 0, 
		"trigger_low_health": false, 
		"trigger_low_health_threshold": 30, 
		"trigger_low_health_linger": 0, 
		"trigger_high_health": false, 
		"trigger_high_health_threshold": 70, 
		"trigger_high_health_linger": 0, 
		"trigger_super_level": false, 
		"trigger_super_level_min": 1, 
		"trigger_super_level_linger": 0, 
		"trigger_after_spawn_projectile": false, 
		"trigger_after_spawn_projectile_duration": 30, 
		"trigger_projectiles_active": false, 
		"trigger_projectiles_active_linger": 0, 
		"trigger_after_take_damage": false, 
		"trigger_after_take_damage_duration": 30, 
		"trigger_after_opponent_take_damage": false, 
		"trigger_after_opponent_take_damage_duration": 30, 
		"trigger_after_perfect_parry": false, 
		"trigger_after_perfect_parry_duration": 30, 
		"trigger_after_burst": false, 
		"trigger_after_burst_duration": 30, 
		"trigger_action_type": false, 
		"trigger_action_type_value": "Attack", 
		"trigger_action_type_linger": 0, 
		"trigger_during_install": false, 
		"trigger_during_install_linger": 0, 
		"trigger_during_taunt": false, 
		"trigger_during_taunt_linger": 0, 
		"trigger_during_parry_combo": false, 
		"trigger_during_parry_combo_linger": 0, 
		"attach_eye_spacing": 6.0, 
		"attach_eye_left_y_offset": 0.0, 
		"attach_eye_right_y_offset": 0.0, 
	}

static func get_setting_min(setting):
	var minimums = {
		"amount": 1, 
		"lifetime": 0.064, 
		"speed_scale": 0.0, 
		"explosiveness": 0.0, 
		"lifetime_randomness": 0.0, 
		"gravity_x": - 100.0, 
		"gravity_y": - 100.0, 
		"rect_size_x": 0.0, 
		"rect_size_y": 0.0, 
		"emission_circle_radius": 0.0, 
		"spread": 0.0, 
		"initial_velocity": - 100.0, 
		"initial_velocity_random": 0.0, 
		"linear_accel": - 100.0, 
		"linear_accel_random": 0.0, 
		"radial_accel": - 100.0, 
		"radial_accel_random": 0.0, 
		"tangential_accel": - 100.0, 
		"tangential_accel_random": 0.0, 
		"orbit_velocity": - 100.0, 
		"orbit_velocity_random": 0.0, 
		"start_scale": 0.0, 
		"end_scale": 0.0, 
		"scale_amount_random": 0.0, 
		"x_offset": - 32.0, 
		"y_offset": - 32.0, 
		"angle": - 360.0, 
		"angle_random": 0.0, 
		"angular_velocity": - 1500.0, 
		"angular_velocity_random": 0.0, 
		"damping": 0.0, 
		"damping_random": 0.0, 
		"framerate": 1, 
		"trigger_during_combo_linger": 0, 
		"trigger_during_melee_attacks_linger": 0, 
		"trigger_while_being_comboed_linger": 0, 
		"trigger_low_health_threshold": 1, 
		"trigger_low_health_linger": 0, 
		"trigger_high_health_threshold": 1, 
		"trigger_high_health_linger": 0, 
		"trigger_super_level_min": 1, 
		"trigger_super_level_linger": 0, 
		"trigger_action_type_linger": 0, 
		"trigger_during_install_linger": 0, 
		"trigger_after_spawn_projectile_duration": 1, 
		"trigger_projectiles_active_linger": 0, 
		"trigger_after_take_damage_duration": 1, 
		"trigger_after_opponent_take_damage_duration": 1, 
		"trigger_after_perfect_parry_duration": 1, 
		"trigger_after_burst_duration": 1, 
	}
	
	return minimums[setting] if minimums.has(setting) else null

static func get_setting_max(setting):
	var maximums = {
		"amount": 32, 
		"lifetime": 2.0, 
		"speed_scale": 30.0, 
		"explosiveness": 1.0, 
		"lifetime_randomness": 1.0, 
		"gravity_x": 100.0, 
		"gravity_y": 100.0, 
		"rect_size_x": 32.0, 
		"rect_size_y": 32.0, 
		"emission_circle_radius": 32.0, 
		"spread": 180.0, 
		"initial_velocity": 100.0, 
		"initial_velocity_random": 1.0, 
		"linear_accel": 100.0, 
		"linear_accel_random": 1.0, 
		"radial_accel": 100.0, 
		"radial_accel_random": 1.0, 
		"tangential_accel": 100.0, 
		"tangential_accel_random": 1.0, 
		"orbit_velocity": 100.0, 
		"orbit_velocity_random": 1.0, 
		"start_scale": 5.0, 
		"end_scale": 5.0, 
		"x_offset": 32.0, 
		"y_offset": 32.0, 
		"scale_amount_random": 1.0, 
		"angle": 360.0, 
		"angle_random": 1.0, 
		"angular_velocity": 1500.0, 
		"angular_velocity_random": 1.0, 
		"damping": 200.0, 
		"damping_random": 1.0, 
		"framerate": 60, 
		"trigger_during_combo_linger": 120, 
		"trigger_during_melee_attacks_linger": 120, 
		"trigger_while_being_comboed_linger": 120, 
		"trigger_low_health_threshold": 100, 
		"trigger_low_health_linger": 120, 
		"trigger_high_health_threshold": 100, 
		"trigger_high_health_linger": 120, 
		"trigger_super_level_min": 9, 
		"trigger_super_level_linger": 120, 
		"trigger_action_type_linger": 120, 
		"trigger_during_install_linger": 120, 
		"trigger_after_spawn_projectile_duration": 120, 
		"trigger_projectiles_active_linger": 120, 
		"trigger_after_take_damage_duration": 120, 
		"trigger_after_opponent_take_damage_duration": 120, 
		"trigger_after_perfect_parry_duration": 120, 
		"trigger_after_burst_duration": 120, 
	}
	return maximums[setting] if maximums.has(setting) else null

func restart():
	$CPUParticles2D.restart()
	if particles_flipped:
		particles_flipped.restart()
	set_enabled(false)
	
	
	_apply_amount()
	if hooks:
		hooks.restart()

func start_emitting():
	
	
	
	.start_emitting()
	_apply_amount()

func _ready():
	set_enabled(false)
	
	





func _ensure_flip_emitter():
	if particles == null or particles_flipped != null:
		return
	particles_flipped = particles.duplicate()
	particles_flipped.name = "CPUParticles2DFlipped"
	particles.get_parent().add_child(particles_flipped)
	particles_flipped.amount = 1
	particles_flipped.emitting = false
	particles_flipped.hide()

func _destroy_flip_emitter():
	if particles_flipped == null:
		return
	particles_flipped.queue_free()
	particles_flipped = null




const BURST_COOLDOWN_FRAMES = 5



const MAX_BURST_CLONES = 20


var active_burst_clones: Array = []


var frames_since_last_burst = BURST_COOLDOWN_FRAMES





var burst_emit_ticks_remaining = 0



var burst_clone_free_in_ticks = 0







func emit_burst():
	if particles == null:
		return
	if frames_since_last_burst < BURST_COOLDOWN_FRAMES:
		return
	frames_since_last_burst = 0
	if hooks:
		hooks.emit_burst()
	
	
	var live_clones: = []
	for c in active_burst_clones:
		if is_instance_valid(c):
			live_clones.append(c)
	active_burst_clones = live_clones
	if active_burst_clones.size() >= MAX_BURST_CLONES:
		var oldest = active_burst_clones.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	var clone = duplicate()
	
	
	
	clone.random_flip = random_flip
	clone.flip_shape = flip_shape
	clone._last_primary_active = _last_primary_active
	clone._last_mirror_active = _last_mirror_active
	clone.particles_flipped = null
	if clone.has_node("CPUParticles2DFlipped"):
		clone.particles_flipped = clone.get_node("CPUParticles2DFlipped")
	clone.attached_to_limb = attached_to_limb
	clone.attached_rotation = attached_rotation
	clone.attached_limb_flipped = attached_limb_flipped
	clone.flip_with_character = flip_with_character
	clone.facing = facing
	clone.default_x_offset = default_x_offset
	clone.default_y_offset = default_y_offset
	clone.default_gravity_x = default_gravity_x
	clone.default_angle = default_angle
	clone.total_amount = total_amount
	
	
	
	
	clone.transform_scale_x = transform_scale_x
	clone.transform_scale_y = transform_scale_y
	clone.transform_rotation = transform_rotation
	get_parent().add_child(clone)
	
	
	
	
	clone.global_position = global_position
	clone.rotation = rotation
	clone.scale = scale
	
	clone.frames_since_last_burst = 0
	clone._start_burst_clone(int(total_amount))
	active_burst_clones.append(clone)





func _start_burst_clone(amount_total: int):
	
	
	
	var speed = particles.speed_scale if particles.speed_scale > 0 else 1.0
	burst_clone_free_in_ticks = max(int(particles.lifetime * 60.0 / speed), 1) * 2
	if particles_flipped == null:
		_clone_burst_one(particles, max(amount_total, 1))
		return
	var amt = max(amount_total, 1)
	var half = amt / 2
	var extra = amt - 2 * half
	var primary_count = half
	var mirror_count = half
	if extra > 0:
		if randi() % 2 == 0:
			primary_count += extra
		else:
			mirror_count += extra
	if primary_count > 0:
		_clone_burst_one(particles, primary_count)
	else:
		particles.emitting = false
	if mirror_count > 0:
		_clone_burst_one(particles_flipped, mirror_count)
	else:
		particles_flipped.emitting = false

func _clone_burst_one(emitter: CPUParticles2D, burst_amount: int):
	
	
	
	emitter.one_shot = true
	emitter.amount = max(burst_amount, 1)
	
	
	
	
	emitter.preprocess = 0.0
	emitter.restart()
	
	
	
	var speed = emitter.speed_scale if emitter.speed_scale > 0 else 1.0
	burst_emit_ticks_remaining = max(int(emitter.lifetime * 60.0 / speed) * 2, 1)

func get_data():
	pass

func set_shape(shape_name):
	var shapes = get_shapes()
	if shape_name in shapes:
		self.shape_name = shape_name
		_apply_shape_texture()

func set_flip_shape(on):
	flip_shape = on
	_apply_shape_texture()

func set_random_flip(on):
	random_flip = on
	if on:
		_ensure_flip_emitter()
	else:
		_destroy_flip_emitter()
	_apply_shape_texture()
	_apply_amount()






func _apply_shape_texture():
	var shapes = get_shapes()
	var tex = shapes.get(shape_name)
	if tex == null:
		return
	var flipped_tex = _flip_texture(tex)
	if random_flip:
		particles.texture = tex
		if particles_flipped:
			particles_flipped.texture = flipped_tex
	else:
		particles.texture = flipped_tex if flip_shape else tex
		if particles_flipped:
			particles_flipped.texture = flipped_tex if flip_shape else tex

func _flip_texture(tex):
	var img = tex.get_data()
	if img == null:
		return tex
	img.flip_x()
	var flipped = ImageTexture.new()
	flipped.create_from_image(img, tex.flags)
	return flipped








var _last_primary_active = true
var _last_mirror_active = true
func _apply_amount():
	var amt = max(int(total_amount), 1)
	if random_flip and particles_flipped:
		var half = amt / 2
		var extra = amt - 2 * half
		var primary_count = half
		var mirror_count = half
		if extra > 0:
			if randi() % 2 == 0:
				primary_count += extra
			else:
				mirror_count += extra
		particles.amount = max(primary_count, 1)
		particles_flipped.amount = max(mirror_count, 1)
		
		
		_last_primary_active = primary_count > 0
		_last_mirror_active = mirror_count > 0
		if not _last_primary_active:
			particles.emitting = false
		if not _last_mirror_active:
			particles_flipped.emitting = false
		particles_flipped.show()
	else:
		particles.amount = amt
		_last_primary_active = true
		_last_mirror_active = false
		if particles_flipped:
			particles_flipped.hide()
			particles_flipped.emitting = false

func set_in_front(on):
	if on:
		show_behind_parent = false

	else:
		show_behind_parent = true


func set_start_color(color):
	start_color = color
	update_color()
	
func set_end_color(color):
	end_color = color
	update_color()

func _physics_process(_delta):
	if not is_instance_valid(Global.current_game):
		if not enabled:
			start_emitting()
			set_enabled(true)
		tick()
	elif Global.current_game:
		
		
		
		
		
		
		
		if auto_start_on_ready:
			
			
			
			
			
			
			
			
			
			
			var g = _owning_game()
			set_enabled(g == null or not (g.game_paused and not ReplayManager.playback))
		elif enabled and burst_clone_free_in_ticks <= 0:
			set_enabled(false)




var _cached_game = null
func _owning_game():
	if is_instance_valid(_cached_game):
		return _cached_game
	var n = get_parent()
	while n != null:
		if n.has_method("is_waiting_on_player"):
			_cached_game = n
			return n
		n = n.get_parent()
	return null

var flip_with_character = true






var attached_to_limb = false
var attached_rotation = 0.0
var attached_limb_flipped = false
var default_x_offset = 0.0
var default_y_offset = 0.0

func tick():
	.tick()
	
	
	
	var extra_rotation = deg2rad(transform_rotation)
	if attached_to_limb:
		rotation = attached_rotation + extra_rotation
		
		
		var flipped = attached_limb_flipped
		if facing == - 1:
			flipped = not flipped
		scale.x = ( - 1 if flipped else 1) * transform_scale_x
		scale.y = transform_scale_y
		particles.gravity.x = default_gravity_x
		particles.angle = default_angle
		
		
		
		particles.position.x = - default_x_offset if facing == - 1 else default_x_offset
		particles.position.y = default_y_offset
	elif flip_with_character:
		rotation = extra_rotation
		scale.x = transform_scale_x
		scale.y = transform_scale_y
		particles.gravity.x = default_gravity_x * facing
		particles.angle = 360 - default_angle if facing == - 1 else default_angle
		particles.position.x = default_x_offset
	else:
		
		
		
		
		
		
		
		rotation = extra_rotation * facing
		particles.gravity.x = default_gravity_x
		particles.angle = default_angle
		scale.x = facing * transform_scale_x
		scale.y = transform_scale_y
		particles.position.x = default_x_offset
	_sync_flipped_transient()
	if frames_since_last_burst < BURST_COOLDOWN_FRAMES:
		frames_since_last_burst += 1
	
	
	
	
	
	if burst_emit_ticks_remaining > 0:
		burst_emit_ticks_remaining -= 1
		if burst_emit_ticks_remaining == 0:
			if particles:
				particles.emitting = false
			if particles_flipped:
				particles_flipped.emitting = false
	
	
	
	if burst_clone_free_in_ticks > 0:
		burst_clone_free_in_ticks -= 1
		if burst_clone_free_in_ticks == 0:
			queue_free()
	
	
	if _emit_fade_ticks_left > 0:
		_emit_fade_ticks_left -= 1






func _sync_flipped_transient():
	if particles_flipped == null:
		return
	particles_flipped.gravity = particles.gravity
	particles_flipped.angle = particles.angle
	particles_flipped.position = particles.position
	var desired = particles.emitting and _last_mirror_active
	if particles_flipped.emitting != desired:
		particles_flipped.emitting = desired

func set_start_alpha(a):

	start_color.a = a
	update_color()

func set_end_alpha(a):
	end_color.a = a
	update_color()

func update_color():
	
	
	
	
	
	var gradient = Gradient.new()
	var alpha_m = clamp(alpha_midpoint, 0.001, 0.999)
	var color_m = clamp(color_midpoint, 0.001, 0.999)
	gradient.set_offset(0, 0.0)
	gradient.set_color(0, _skewed_color_alpha(0.0, color_m, alpha_m))
	gradient.set_offset(1, 1.0)
	gradient.set_color(1, _skewed_color_alpha(1.0, color_m, alpha_m))
	if abs(color_m - 0.5) > 0.0001 or abs(alpha_m - 0.5) > 0.0001:
		
		
		
		var inner_positions = [color_m] if abs(color_m - alpha_m) < 0.0001 else _sorted_distinct([color_m, alpha_m])
		for t in inner_positions:
			gradient.add_point(t, _skewed_color_alpha(t, color_m, alpha_m))
	particles.color_ramp = gradient
	if particles_flipped:
		particles_flipped.color_ramp = gradient

func _skewed_color_alpha(t: float, color_m: float, alpha_m: float) -> Color:
	var c = start_color.linear_interpolate(end_color, _skew(t, color_m))
	c.a = lerp(start_color.a, end_color.a, _skew(t, alpha_m))
	return c




func _skew(t: float, m: float) -> float:
	if t <= m:
		return (t / m) * 0.5
	return 0.5 + ((t - m) / (1.0 - m)) * 0.5

func _sorted_distinct(arr: Array) -> Array:
	arr.sort()
	var out: = []
	for v in arr:
		if out.size() == 0 or abs(out[ - 1] - v) > 0.0001:
			out.append(v)
	return out

func set_color_midpoint(m):
	color_midpoint = m
	update_color()

func set_alpha_midpoint(m):
	alpha_midpoint = m
	update_color()

func set_scale_midpoint(m):
	scale_midpoint = m
	update_scale()

func set_transform_scale_x(s):
	transform_scale_x = s
	scale = Vector2(transform_scale_x, transform_scale_y)

func set_transform_scale_y(s):
	transform_scale_y = s
	scale = Vector2(transform_scale_x, transform_scale_y)

func set_transform_rotation(r):
	transform_rotation = r
	
	
	
	rotation = deg2rad(r)

func set_start_scale(sc):
	start_scale = sc
	update_scale()

func set_end_scale(sc):
	end_scale = sc
	update_scale()

func update_scale():
	var curve = Curve.new()
	var max_ = max(start_scale, end_scale)
	var start = start_scale
	var end = end_scale
	if max_ > 0:
		start = start_scale / max_
		end = end_scale / max_
	particles.scale_amount = max_
	curve.add_point(Vector2(0, start))
	var sm = clamp(scale_midpoint, 0.001, 0.999)
	if abs(sm - 0.5) > 0.0001:
		
		
		
		curve.add_point(Vector2(sm, (start + end) * 0.5))
	curve.add_point(Vector2(1, end))
	
	
	
	for i in range(curve.get_point_count()):
		curve.set_point_left_mode(i, Curve.TANGENT_LINEAR)
		curve.set_point_right_mode(i, Curve.TANGENT_LINEAR)
	particles.scale_amount_curve = curve
	if particles_flipped:
		particles_flipped.scale_amount = max_
		particles_flipped.scale_amount_curve = curve

const EMISSION_SHAPE_NAMES = {
	"rectangle": 2, 
	"circle": 1, 
}

func set_emission_shape(shape_name):
	if not (shape_name in EMISSION_SHAPE_NAMES):
		return
	var enum_val = EMISSION_SHAPE_NAMES[shape_name]
	particles.emission_shape = enum_val
	if particles_flipped:
		particles_flipped.emission_shape = enum_val

func set_emission_circle_radius(r):
	particles.emission_sphere_radius = r
	if particles_flipped:
		particles_flipped.emission_sphere_radius = r

func set_rect_size_x(x):

	var ext = Vector2(x, particles.get_emission_rect_extents().y)
	particles.set_emission_rect_extents(ext)
	if particles_flipped:
		particles_flipped.set_emission_rect_extents(ext)

func set_rect_size_y(y):
	var ext = Vector2(particles.get_emission_rect_extents().x, y)
	particles.set_emission_rect_extents(ext)
	if particles_flipped:
		particles_flipped.set_emission_rect_extents(ext)

func set_gravity_x(x):
	default_gravity_x = x
	particles.gravity.x = x
	if particles_flipped:
		particles_flipped.gravity.x = x

func set_gravity_y(y):
	particles.gravity.y = y
	if particles_flipped:
		particles_flipped.gravity.y = y

func set_x_offset(x):
	default_x_offset = x
	particles.position.x = x
	if particles_flipped:
		particles_flipped.position.x = x

func set_y_offset(y):
	default_y_offset = y
	particles.position.y = y
	if particles_flipped:
		particles_flipped.position.y = y

var custom_preprocess: = false
var custom_preprocess_value: = 0.0





var preprocess_on_retrigger: = false





var _has_been_hidden: = false

func set_lifetime(lifetime):
	particles.lifetime = lifetime
	particles.preprocess = _preprocess_for(lifetime)
	if particles_flipped:
		particles_flipped.lifetime = lifetime
		particles_flipped.preprocess = _preprocess_for(lifetime)





func _preprocess_for(lifetime) -> float:
	if custom_preprocess:
		return custom_preprocess_value
	return 0.0 if no_preprocess else lifetime

func set_custom_preprocess(on):
	custom_preprocess = on
	set_lifetime(particles.lifetime)

func set_custom_preprocess_value(value):
	custom_preprocess_value = value
	set_lifetime(particles.lifetime)

func set_preprocess_on_retrigger(on):
	preprocess_on_retrigger = on







func restart_emission():
	var pp = _preprocess_for(particles.lifetime)
	if _has_been_hidden and not preprocess_on_retrigger:
		pp = 0.0
	particles.preprocess = pp
	if particles_flipped:
		particles_flipped.preprocess = pp
	restart()

func set_angle(angle):
	default_angle = angle
	particles.angle = angle
	if particles_flipped:
		particles_flipped.angle = angle

func set_flip_with_character(on):
	flip_with_character = on

var cap_framerate_enabled = false
var framerate_value = 60

func set_cap_framerate(on):
	cap_framerate_enabled = on
	_apply_framerate()

func set_framerate(value):
	framerate_value = int(value)
	_apply_framerate()

func _apply_framerate():
	var fps = framerate_value if cap_framerate_enabled else 0
	particles.fixed_fps = fps
	if particles_flipped:
		particles_flipped.fixed_fps = fps

const TRIGGER_META_PARAMS = [
	"disable_on_ko", 
	"dynamic_triggers", 
	"dynamic_one_shot", 
	"triggers_inverted", 
	"trigger_during_combo", "trigger_during_combo_linger", 
	"trigger_during_melee_attacks", "trigger_during_melee_attacks_linger", 
	"trigger_while_being_comboed", "trigger_while_being_comboed_linger", 
	"trigger_low_health", "trigger_low_health_threshold", "trigger_low_health_linger", 
	"trigger_high_health", "trigger_high_health_threshold", "trigger_high_health_linger", 
	"trigger_super_level", "trigger_super_level_min", "trigger_super_level_linger", 
	"trigger_after_spawn_projectile", "trigger_after_spawn_projectile_duration", 
	"trigger_projectiles_active", "trigger_projectiles_active_linger", 
	"trigger_after_take_damage", "trigger_after_take_damage_duration", 
	"trigger_after_opponent_take_damage", "trigger_after_opponent_take_damage_duration", 
	"trigger_after_perfect_parry", "trigger_after_perfect_parry_duration", 
	"trigger_after_burst", "trigger_after_burst_duration", 
	"trigger_action_type", "trigger_action_type_value", "trigger_action_type_linger", 
	"trigger_during_install", "trigger_during_install_linger", 
]



var style_aura_low_health_tick = - 100000
var style_aura_high_health_tick = - 100000
var style_aura_super_level_tick = - 100000
var style_aura_action_type_tick = - 100000

var style_aura_low_health_started_tick = - 100000
var style_aura_high_health_started_tick = - 100000
var style_aura_super_level_started_tick = - 100000
var style_aura_action_type_started_tick = - 100000
var was_low_health_active = false
var was_high_health_active = false
var was_super_level_active = false
var was_action_type_active = false



var _threshold_rising_edge_initialized = false



var _consumed_event_ticks = {}





var _aura_emit_active = false





var _emit_fade_ticks_left = 0



func mark_emission_stopped():
	var speed = particles.speed_scale if particles.speed_scale > 0 else 1.0
	_emit_fade_ticks_left = max(int(particles.lifetime * 60.0 / speed), 1)



func emission_faded() -> bool:
	return _emit_fade_ticks_left <= 0

func set_parameter(param, value):
	var max_value = get_setting_max(param)
	var min_value = get_setting_min(param)
	if max_value and value > max_value:
		value = max_value
	if min_value and value < min_value:
		value = min_value
	
	
	if param in TRIGGER_META_PARAMS:
		return
	
	
	if param == "amount":
		total_amount = value
		_apply_amount()
		return
	if not (param in custom_set):
		particles.set(param, value)
		if particles_flipped:
			particles_flipped.set(param, value)
	else:
		call(custom_set[param], value)

func load_defaults():
	load_settings(get_default())

func load_settings(settings):
	if settings:
		for setting in settings:
			set_parameter(setting, settings[setting])
