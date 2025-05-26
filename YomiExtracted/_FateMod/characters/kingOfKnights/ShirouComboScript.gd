extends CharacterState

func _enter():
	._enter() 
	host.comboAttackCD = 300 
	
func is_usable():
	return .is_usable() and host.comboAttackCD == 0
