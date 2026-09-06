extends ThrowState

func _enter():
	
	host.opponent.take_damage(40)
	
func _tick():
	host.opponent.change_state("Knockdown")
	host.opponent.hitlag_ticks = 1
	
