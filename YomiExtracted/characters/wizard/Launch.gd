extends WizardState

export  var redirect = false

func _frame_0():
	if redirect:
		go()
	interruptible_on_opponent_turn = false

func _frame_3():
	if not redirect:
		go()

func _frame_9():
	if not redirect:
		interruptible_on_opponent_turn = true

func go():
	if redirect:
		host.hover_left -= host.TK_LAUNCH_HOVER_AMOUNT
	var obj = host.obj_from_name(host.boulder_projectile)
	if obj:
		var dir = xy_to_dir(data.x, data.y)
		if redirect:
			obj.launch_redirect(dir)
		else:
			obj.launch(dir)
		host.play_sound("Telekinesis")

func is_usable():
	var obj = host.obj_from_name(host.boulder_projectile)
	if obj:
		var sname = obj.current_state().state_name
		var in_flight = sname == "Launch" or sname == "LaunchRedirect"
		if redirect and not in_flight:
			return false
		if not redirect and in_flight:
			return false
		
		
		
		
		if redirect and (obj.get("got_perfect_parried") or obj.get("got_push_blocked")):
			return false
	return host.boulder_projectile != null and .is_usable()

