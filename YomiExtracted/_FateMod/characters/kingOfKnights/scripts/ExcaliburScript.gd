extends KokNormalAttackState

var prevHitLag = 0
var cutscenePlaying
var projectile
var tickForCutscene = 0

export (PackedScene) var groundHitParticle
export (PackedScene) var airHitParticle
export (PackedScene) var airAttackParticle
export (PackedScene) var groundAttackParticle
export (int) var cutsceneTPF


func _enter():
	$"%ExcaliburChargeUp".start_emitting()
	
func _exit():
	
	if host.opponent.position.y > 5:
		host.state_machine.queue_state("ExcaliburAirVar")
	else:
		host.state_machine.queue_state("ExcaliburGroundVar")


func _frame_272():
	$"%ExcaliburChargeUp".stop_emitting()
	if !host.is_ghost:
		host.opponent.hitlag_ticks = prevHitLag
	$"%ExcaliburCutscene".hide()
	$"%CutsceneFiller".hide()
	host.quick_ui_revealer()
	
func _frame_14():
	prevHitLag = host.opponent.hitlag_ticks
	cutscenePlaying = true
	prevHitLag = host.opponent.hitlag_ticks
	busy_interrupt_type = BusyInterrupt.None
	
func _frame_93():
	host.quick_ui_hider()
	if (projectile):
		projectile.disable()
	$"%ExcaliburCutscene".show()
	$"%ExcaliburCutscene".frame = 0
	$"%CutsceneFiller".show()

func _tick():
	if cutscenePlaying:
		host.opponent.hitlag_ticks = 1
		tickForCutscene += 1
		if tickForCutscene == cutsceneTPF:
			tickForCutscene = 0
			$"%ExcaliburCutscene".frame += 1

func spawn_exported_projectile():
	print(host.name)
	if projectile_scene:
		var pos = get_projectile_pos()
		projectile = host.spawn_object(projectile_scene, pos.x, pos.y, true, get_projectile_data(), projectile_local_pos)
		if projectile_match_facing:
			projectile.set_facing(host.get_facing_int())
		process_projectile(projectile)
