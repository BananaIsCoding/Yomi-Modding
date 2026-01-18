extends ObjectState

func _frame_0():
	$"%Spear".start_emitting() 

func _frame_16():
	$"%Spear".stop_emitting()
	$"%Spear".hide()
	$"%meow".start_emitting()
	
func _frame_20():
	$"%meow".stop_emitting()

func _frame_30():
	host.disable()
