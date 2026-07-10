tool

extends Hitbox

var groundExcaliburHitEffect = preload("res://_FateMod/characters/kingOfKnights/effects/Excalibur/ExcaliburGroundHitEffect.tscn")

var isEffectAlrSpawned

func hit(obj):
	.hit(obj)
	
	if (!isEffectAlrSpawned):
		isEffectAlrSpawned = true
		if not host.is_ghost:
			print("Spawned")
		spawn_particle(groundExcaliburHitEffect, obj, Vector2(0,0))
