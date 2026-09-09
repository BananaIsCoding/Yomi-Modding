extends "res://_FateMod/characters/kingOfKnights/scripts/BaseActionOverwrite/KOKThrow.gd"

func _enter():
	._enter()
	host.opponent.take_damage(40)
	
func _tick():
	._tick()
	host.opponent.change_state("Knockdown")
	host.opponent.hitlag_ticks = 1
	
