extends BaseProjectile





func tick():
	if creator and not creator.disabled:
		var pos = creator.get_pos()
		set_pos(pos.x, pos.y)
	.tick()



func on_got_push_blocked():
	if creator and not creator.disabled and creator.has_method("reverse_fire_direction"):
		creator.reverse_fire_direction()
