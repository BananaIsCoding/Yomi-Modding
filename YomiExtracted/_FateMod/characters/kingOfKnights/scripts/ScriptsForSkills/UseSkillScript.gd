extends CharacterState

func _enter():
	if host.is_ghost:
		print("Ahhh a ghost")
		return
	randomize()
	var num = randi() % 3
	if num == 0:
		host.change_state("Skill1")
	elif num == 1:
		host.change_state("Skill2")
	elif num == 2:
		host.change_state("Skill3")
	print(host.current_tick)
	print( ReplayManager.frames[host.id][host.current_tick]["action"])
	print(ReplayManager.frames)

func is_usable():
	return .is_usable() and host.skillCd == 0
