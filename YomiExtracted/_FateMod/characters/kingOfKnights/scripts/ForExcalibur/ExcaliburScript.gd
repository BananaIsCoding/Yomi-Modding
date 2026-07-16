extends KokNormalAttackState

## Variables ##

var prevHitLag = 0
var cutscenePlaying
var tickForCutscene = 0
var chargeComplete = false

onready var swordChargeUp = $"%ExcaliburSwordSprite"
onready var excaliburCutscene = $"%ExcaliburCutscene"
onready var chargeUpEffect = $"%ExcaliburChargeUp"
onready var cutsceneFiller = $"%CutsceneFiller"

export (int) var cutsceneTPF

func _enter():
	chargeUpEffect.start_emitting()
	
	swordChargeUp.frame = 0
	swordChargeUp.visible = true
	swordChargeUp.playing = true

func _exit():
	
	chargeUpEffect.stop_emitting()
	swordChargeUp.visible = false
	swordChargeUp.playing = false
	
	if not chargeComplete:
		return

	if host.opponent.position.y < -50:
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
	swordChargeUp.playing = false
	swordChargeUp.visible = false
		
	var playerPos = host.get_pos()
	var opponentPos =  host.opponent.get_pos()
	
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
	chargeComplete = true

