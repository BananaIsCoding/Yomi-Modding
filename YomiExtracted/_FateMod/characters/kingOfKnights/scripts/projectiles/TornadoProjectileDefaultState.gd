extends DirProjectileDefault

var movePerTick := 0

func _enter():
	._enter()
	move_speed = data["speed"]
	lifetime = data["lifetime"]
	for hitbox in all_hitbox_nodes:
		hitbox.dir_x = str(float(hitbox.dir_x) * float(move_speed))
		print (hitbox.dir_x)
		hitbox.damage += hitbox.damage * data["dmgBoost"]


func _tick():
	var pos = host.get_pos()
	host.update_grounded()
	if fizzle_on_ground and current_tick > 1 and not hit_something and host.is_grounded() or pos.x <= - host.stage_width or pos.x >= host.stage_width:
		fizzle()
		host.hurtbox.width = 0
		host.hurtbox.height = 0
		pass
	
	var vel = host.get_vel()
	if not fixed.eq(vel.y, "0"):
		last_y_vel = vel.y
	
	if host.is_grounded() and bounce_on_ground:
		host.set_grounded(false)
		host.move_directly(0, - 1)
		if vel:
			host.set_vel(vel.x, fixed.mul(fixed.abs(last_y_vel), "-0.75"))
		num_bounces -= 1
		if num_bounces < 0:
			fizzle()
	
	if current_tick > lifetime:
		fizzle()
		host.hurtbox.width = 0
		host.hurtbox.height = 0
	
	elif not hit_something:
		var dir
		if not homing:
			dir = data["dir"]
			var dir_x = fixed.mul(dir.x, str(host.get_facing_int())) if relative_data_dir else dir.x
			var move_vec = fixed.normalized_vec_times(dir_x, str(dir.y), move_speed)
			host.move_directly(move_vec.x, dir.y)
			
			#host.sprite.rotation = float(fixed.vec_to_angle(dir.x, dir.y))
			#host.particles.rotation = float(fixed.vec_to_angle(dir.x, dir.y))
			#host.set_facing(fixed.sign(dir_x))
		else:
			var opponent = host.get_opponent()
			if opponent == null:
				return
			var target = host.obj_local_center(opponent)
			var current = fixed.normalized_vec(vel.x, vel.y)
			var desired = fixed.normalized_vec(str(target.x), str(target.y))
			var steering_x = fixed.sub(desired.x, current.x)
			var steering_y = fixed.sub(desired.y, current.y)
			var steer_force = fixed.normalized_vec_times(steering_x, steering_y, homing_turn_speed)
			var force_x = fixed.mul(current.x, homing_accel)
			var force_y = fixed.mul(current.y, homing_accel)
			if not fixed.eq(vel.x, "0"):
				host.set_facing(1 if fixed.gt(vel.x, "0") else - 1)
			host.apply_force(force_x, force_y)
			host.apply_force(steer_force.x, steer_force.y)
			host.apply_forces()
			
			host.update_data()
			var new_vel = host.get_vel()
			if fixed.gt(fixed.vec_len(new_vel.x, new_vel.y), max_homing_speed):
				var clamped_vel = fixed.normalized_vec_times(new_vel.x, new_vel.y, max_homing_speed)
				host.set_vel(clamped_vel.x, clamped_vel.y)
			host.sprite.rotation = float(fixed.vec_to_angle(fixed.mul(new_vel.x, str(host.get_facing_int())), new_vel.y))

func _on_hit_something(obj, hitbox):
	if obj.is_in_group("Fighter"):
		obj.reset_momentum()
	._on_hit_something(obj, hitbox)
