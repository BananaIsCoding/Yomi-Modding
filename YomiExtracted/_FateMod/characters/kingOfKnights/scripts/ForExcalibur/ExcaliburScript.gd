extends KokNormalAttackState

## Variables ##

var prevHitLag = 0
var cutscenePlaying
var tickForCutscene = 0
var chargeComplete = false
var opponentHeight = 0
var setUpComplete = false
var prevCamPos
var cam

onready var swordChargeUp = $"%ExcaliburSwordSprite"
onready var excaliburCutscene = $"%ExcaliburCutscene"
onready var chargeUpEffect = $"%ExcaliburChargeUp"
onready var cutsceneFiller = $"%CutsceneFiller"
onready var cutsceneChargeParticles = $"%ExcaliburCutsceneChargeUp"

export (int) var cutsceneTPF

## Functions ##

func _enter():
	._enter()
	if setUpComplete or host.is_ghost:
		return
	setUpComplete = true

func _frame_0():
	# Starting up the effects
	chargeUpEffect.start_emitting()
	swordChargeUp.frame = 0
	swordChargeUp.visible = true
	swordChargeUp.playing = true

func _exit():
	._enter()
	# Ends effects if it haven't yet
	chargeUpEffect.stop_emitting()
	cutsceneChargeParticles.stop_emitting()
	swordChargeUp.visible = false
	swordChargeUp.playing = false
	# Release camera from following player
	host.release_camera_focus()
	
	# If player was hit before move can complete
	if not chargeComplete:
		return
	
	# switchs the variant based off enemies' altitude
	if opponentHeight < -50:
		host.state_machine.queue_state("ExcaliburAirVar")
	else:
		host.state_machine.queue_state("ExcaliburGroundVar")

func _tick():
	if cutscenePlaying:
		# Stops enemy in place
		host.opponent.hitlag_ticks += 1
		
		# Ensure cutscene is correctly 
		host.set_camera_zoom(1.0)
		host.grab_camera_focus()
		
		# To change cutscene frame every x ticks
		tickForCutscene += 1
		if tickForCutscene == cutsceneTPF:
			tickForCutscene = 0
			excaliburCutscene.frame += 1

## Specific Frame stuff: ##

func _frame_14():
	cutscenePlaying = true
	prevHitLag = host.opponent.hitlag_ticks
	busy_interrupt_type = BusyInterrupt.None

func _frame_93():
	
	swordChargeUp.playing = false
	swordChargeUp.visible = false
	
	cutsceneChargeParticles.start_emitting()
	
	if not host.is_ghost:
		cam = Network.game.camera
		prevCamPos = cam.global_position
	
	# Set up for cutscene 
	host.quick_ui_hider()
	
	host.grab_camera_focus()
	host.set_camera_zoom(1.0)
	
	var playerPos = host.get_pos()
	var opponentPos =  host.opponent.get_pos()
	
	var game = Global.current_game
	excaliburCutscene.show()
	tickForCutscene = 0
	excaliburCutscene.frame = 0
	cutsceneFiller.show()

func _frame_272():
	# Stopping the cutscene 
	chargeUpEffect.stop_emitting()
	cutsceneChargeParticles.stop_emitting()
	
	excaliburCutscene.hide()
	cutsceneFiller.hide()
	host.quick_ui_revealer()
	chargeComplete = true
	
	opponentHeight = host.opponent.position.y
