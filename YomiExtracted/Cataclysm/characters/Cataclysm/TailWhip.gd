extends CharacterState

func _frame_0():
	$"%Dash".start_emitting() 
	if data:
		var dir= xy_to_dir(data.x, data.y, "6")
		host.apply_force(dir.x, dir.y)
		
func _frame_1():
	$"%Dash".stop_emitting() 

func _exit():
	$"%Dash".stop_emitting() 
