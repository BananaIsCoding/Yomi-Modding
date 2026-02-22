extends KokNormalAttackState

var prevHitLag = 0
var cutscene
var projectile

export (PackedScene) var groundHitParticle
export (PackedScene) var airHitParticle
export (PackedScene) var airAttackParticle
export (PackedScene) var groundAttackParticle


func _enter():
	$"%ExcaliburChargeUp".start_emitting()

func _exit():
	$"%ExcaliburChargeUp".stop_emitting()
	if (projectile):
		projectile.disable()
	if !host.is_ghost:
		host.opponent.hitlag_ticks = prevHitLag
	#host.quick_ui_revealer()

func _frame_93():
	#host.quick_ui_hider()
	prevHitLag = host.opponent.hitlag_ticks
	cutscene = true
	
func _tick():
	if cutscene:
		host.opponent.hitlag_ticks = 1

func spawn_exported_projectile():
	if projectile_scene:
		var pos = get_projectile_pos()
		projectile = host.spawn_object(projectile_scene, pos.x, pos.y, true, get_projectile_data(), projectile_local_pos)
		if projectile_match_facing:
			projectile.set_facing(host.get_facing_int())
		process_projectile(projectile)
