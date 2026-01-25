extends CharacterState

var num

func enter():
	randomize()
	num = randi() % 3
	
	if num == 0:
		print("skill1")
	elif num == 1:
		print("skill2")
	elif num == 2:
		print("skill3")
		
func _exit():
	if num == 0:
		print("using skill1")
	elif num == 1:
		print("using skill2")
	elif num == 2:
		print("using skill3")
	host.skillCd = 300

func is_usable():
	return .is_usable() and host.skillCd == 0
