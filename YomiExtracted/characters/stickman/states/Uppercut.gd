extends CharacterState

onready var hitbox_2 = $Hitbox2

export  var air = false





var was_neutral_hit = false

func _frame_0():

	was_neutral_hit = not air and host.opponent != null and not host.opponent.is_in_hurt_state(false)
	if host.initiative and host.is_grounded():

		host.start_invulnerability()



	var vel = host.get_vel()
	if air_type != AirType.Aerial:
		if fixed.sign(vel.x) != host.get_facing_int():
			host.reset_momentum()
		else:
			host.reset_momentum()
			host.set_vel(fixed.div(vel.x, "3"), vel.y)

	hitbox_2.block_punishable = false

func on_got_blocked():
	hitbox_2.block_punishable = true






func __on_hit_something(obj, hitbox):
	_on_hit_something(obj, hitbox)
	host._on_hit_something(obj, hitbox)

func _on_hit_something(obj, hitbox):

	if not air:
		host.apply_force("0", "6")
		if was_neutral_hit:
			host.cancel_opponent_hitstun_pending = true
			host.cancel_opponent_hitstun_countdown = - 1
	
	
	
	
	
	
	
	._on_hit_something(obj, hitbox)

func _tick():
	host.apply_grav()
	host.apply_forces()
	if host.is_grounded() and current_tick > force_tick:
		return "UppercutLanding"

func _frame_4():
	host.end_invulnerability()


func _frame_8():
	host.end_throw_invulnerability()

func _frame_9():
	host.end_invulnerability()
