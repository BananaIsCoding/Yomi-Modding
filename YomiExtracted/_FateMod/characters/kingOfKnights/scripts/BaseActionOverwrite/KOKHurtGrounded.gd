extends HurtGrounded

export (Array, String) var highAnimNameArray = ["HurtGroundedHigh"]
export (Array, String) var midBackAnimNameArray = ["HurtGroundedMid"]
export (Array, String) var lowAnimNameArray = ["HurtGroundedLow"]

func _enter():
	can_act = false
	hitbox = data["hitbox"]
	match hitbox.hit_height:
		Hitbox.HitHeight.High:
			anim_name = "HurtGroundedHigh"
		Hitbox.HitHeight.Mid:
			anim_name = "HurtGroundedMid"
		Hitbox.HitHeight.Low:
			anim_name = "HurtGroundedLow"
	hitstun = global_hitstun_modifier(hitbox.hitstun_ticks + hitstun_modifier(hitbox))
	wall_slam = hitbox.wall_slam and host.wall_slams < host.MAX_WALL_SLAMS
	counter = hitbox.counter_hit
	if counter:
		host.opponent.counterhit_this_turn = true

	var x = get_x_dir(hitbox)
	host.set_facing(Utils.int_sign(fixed.round(x)) * - 1)
	var y = hitbox.dir_y
	if hitbox.vacuum:
		var vacuum_dir = get_vacuum_dir(hitbox)
		x = vacuum_dir.x
		y = vacuum_dir.y
	elif hitbox.send_away_from_center:
		var vacuum_dir = get_vacuum_dir(hitbox)
		x = fixed.mul(vacuum_dir.x, "-1")
		y = fixed.mul(vacuum_dir.y, "-1")

	var knockback_force = fixed.normalized_vec_times(x, y, hitbox.knockback)
	knockback_force.y = "0"

	var di_force = fixed.vec_mul(host.get_scaled_di(host.current_di).x, "0", fixed.mul(DI_STRENGTH, hitbox.di_modifier))
	if hitbox.hitbox_type == Hitbox.HitboxType.Burst:
		di_force.x = "0"
		di_force.y = "0"
	else:
		hitstun = di_shave_hitstun(hitstun, x, "0")
		knockback_force = fixed.vec_mul(knockback_force.x, knockback_force.y, host.knockback_taken_modifier)
	if host.braced_attack:
		hitstun = brace_shave_hitstun(hitstun)
	if host.touching_wall and not wall_slam:
		knockback_force.x = "0"
	var force_x = fixed.add(knockback_force.x, di_force.x)
	var force_y = fixed.add(knockback_force.y, di_force.y)
	host.apply_force(force_x, force_y)
	if dizzy:
		host.start_throw_invulnerability()
