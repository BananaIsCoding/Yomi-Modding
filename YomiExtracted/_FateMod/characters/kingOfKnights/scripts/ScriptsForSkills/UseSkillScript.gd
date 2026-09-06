extends CharacterState

func _enter():
	if host.is_ghost:
#		print("Ahhh a ghost")
		return
	
	# Picks a random number and use it to determine what skill will be used
	# Change the state
	# And update replay or it will randomise each time it is replayed
	# (I need to check if that force change made replay 1 tick less accurate)
	randomize()
	var num = randi() % 3
	if num == 0:
		host.change_state("Skill1")
		ReplayManager.frames[host.id][host.current_tick]["action"] = "Skill1"
	elif num == 1:
		host.change_state("Skill2")
		ReplayManager.frames[host.id][host.current_tick]["action"] = "Skill2"
	elif num == 2:
		host.change_state("Skill3")
		ReplayManager.frames[host.id][host.current_tick]["action"] = "Skill3"

func is_usable():
	return .is_usable() and host.skillCd == 0
