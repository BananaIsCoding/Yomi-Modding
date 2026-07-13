extends KokNormalAttackState

## Variables ##

var prevHitLag = 0
var cutscenePlaying
var projectile
var tickForCutscene = 0

onready var excaliburCutscene = $"%ExcaliburCutscene"
onready var chargeUpEffect = $"%ExcaliburChargeUp"
onready var cutsceneFiller = $"%CutsceneFiller"

export (int) var cutsceneTPF

func _enter():
	
	chargeUpEffect.start_emitting()

func _exit():
	
	if host.opponent.position.y > 5:
		host.state_machine.queue_state("ExcaliburAirVar")
	else:
		host.state_machine.queue_state("ExcaliburGroundVar")
		

func _tick():
	if cutscenePlaying:
		host.opponent.hitlag_ticks += 1
		host.set_camera_zoom(1.0)
		tickForCutscene += 1
		if tickForCutscene == cutsceneTPF:
			tickForCutscene = 0
			excaliburCutscene.frame += 1

## Specific Frame stuff: ##

func _frame_14():
	prevHitLag = host.opponent.hitlag_ticks
	cutscenePlaying = true
	prevHitLag = host.opponent.hitlag_ticks
	busy_interrupt_type = BusyInterrupt.None

func _frame_93():
	host.quick_ui_hider()
	host.set_camera_zoom(1.0)
	if (projectile):
		projectile.disable()
		
	var playerPos = host.get_pos()
	var opponentPos =  host.opponent.get_pos()
	
	print(Global.current_game.camera.global_position)
	print(Global.current_game.camera.position)
	
	var midpoint = (Vector2(playerPos.x + opponentPos.x, playerPos.y + opponentPos.y)) / 2
	var game = Global.current_game
	excaliburCutscene.position = game.camera.position + Vector2(game.char_distance, -10)
	excaliburCutscene.show()
	excaliburCutscene.frame = 0
	cutsceneFiller.show()

func _frame_272():
	# Stopping the cutscene 
	chargeUpEffect.stop_emitting()
	excaliburCutscene.hide()
	cutsceneFiller.hide()
	host.quick_ui_revealer()

## Utility Functions: ##

func spawn_exported_projectile():
	if projectile_scene:
		var pos = get_projectile_pos()
		projectile = host.spawn_object(projectile_scene, pos.x, pos.y, true, get_projectile_data(), projectile_local_pos)
		if projectile_match_facing:
			projectile.set_facing(host.get_facing_int())
		process_projectile(projectile)
